import 'dart:convert';

import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/dashboard/home/tab_bar/credentials/models/activity/activity.dart';
import 'package:altme/did/did.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:bloc/bloc.dart';
import 'package:credential_manifest/credential_manifest.dart';
import 'package:did_kit/did_kit.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:key_generator/key_generator.dart';

import 'package:secure_storage/secure_storage.dart';
import 'package:uuid/uuid.dart';

part 'wallet_cubit.g.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit({
    required this.repository,
    required this.secureStorageProvider,
    required this.profileCubit,
    required this.homeCubit,
    required this.credentialListCubit,
    required this.keyGenerator,
    required this.didCubit,
    required this.didKitProvider,
    required this.advanceSettingsCubit,
  }) : super(WalletState());

  final CredentialsRepository repository;
  final SecureStorageProvider secureStorageProvider;
  final ProfileCubit profileCubit;
  final HomeCubit homeCubit;
  final CredentialListCubit credentialListCubit;
  final KeyGenerator keyGenerator;
  final DIDCubit didCubit;
  final DIDKitProvider didKitProvider;
  final AdvanceSettingsCubit advanceSettingsCubit;

  Future initialize({required String? ssiKey}) async {
    if (ssiKey != null) {
      if (ssiKey.isNotEmpty) {
        await loadAllCredentialsFromRepository();
      }
    }
  }

  Future<void> setCurrentWalletAccount(int index) async {
    emit(state.loading());
    await secureStorageProvider.set(
      SecureStorageKeys.currentTezosIndex,
      index.toString(),
    );
    emit(
      state.copyWith(
        status: WalletStatus.populate,
        currentCryptoIndex: index,
      ),
    );
  }

  Future<void> createCryptoWallet({
    String? accountName,
    required String mnemonicOrKey,
    required bool isImported,
    Function(CryptoAccount cryptoAccount)? onComplete,
  }) async {
    int index = 0;

    if (!isImported) {
      final String? derivePathIndex =
          await secureStorageProvider.get(SecureStorageKeys.derivePathIndex);

      if (derivePathIndex != null && derivePathIndex.isNotEmpty) {
        index = int.parse(derivePathIndex) + 1;
      }

      await secureStorageProvider.set(
        SecureStorageKeys.derivePathIndex,
        index.toString(),
      );
    }

    late String tezosKey;
    late String tezosWalletAddress;
    late String tezosSecretKey;

    final isSecretKey = mnemonicOrKey.startsWith('edsk') ||
        mnemonicOrKey.startsWith('spsk') ||
        mnemonicOrKey.startsWith('p2sk') ||
        mnemonicOrKey.startsWith('0x');

    tezosKey = isSecretKey
        ? await keyGenerator.jwkFromSecretKey(
            secretKey: mnemonicOrKey,
          )
        : await keyGenerator.jwkFromMnemonic(
            mnemonic: mnemonicOrKey,
            accountType: AccountType.tezos,
            derivePathIndex: index,
          );

    tezosSecretKey = isSecretKey
        ? mnemonicOrKey
        : await keyGenerator.secretKeyFromMnemonic(
            mnemonic: mnemonicOrKey,
            accountType: AccountType.tezos,
            derivePathIndex: index,
          );

    tezosWalletAddress = isSecretKey
        ? await keyGenerator.walletAddressFromSecretKey(
            secretKey: tezosSecretKey,
            accountType: AccountType.tezos,
          )
        : await keyGenerator.walletAddressFromMnemonic(
            mnemonic: mnemonicOrKey,
            accountType: AccountType.tezos,
            derivePathIndex: index,
          );

    String name = 'My Account ${index + 1}';

    if (accountName != null && accountName.isNotEmpty) {
      name = accountName;
    }

    final CryptoAccountData cryptoAccountData = CryptoAccountData(
      name: name,
      key: tezosKey,
      walletAddress: tezosWalletAddress,
      secretKey: tezosSecretKey,
      isImported: isImported,
      blockchainType: BlockchainType.tezos,
    );

    final cryptoAccounts = List.of(state.cryptoAccount.data)
      ..add(cryptoAccountData);

    final CryptoAccount cryptoAccount = CryptoAccount(data: cryptoAccounts);
    final String cryptoAccountString = jsonEncode(cryptoAccount);
    await secureStorageProvider.set(
      SecureStorageKeys.cryptoAccount,
      cryptoAccountString,
    );

    onComplete?.call(cryptoAccount);
    emitCryptoAccount(cryptoAccount);

    /// set new account as current
    await setCurrentWalletAccount(cryptoAccounts.length - 1);

    final credential = await generateAssociatedWalletCredential(
      accountName: cryptoAccountData.name,
      walletAddress: tezosWalletAddress,
      cryptoKey: tezosKey,
    );
    if (credential != null) {
      await insertCredential(credential);
    }
  }

  Future<void> editCryptoAccountName({
    required String newAccountName,
    required int index,
    Function(CryptoAccount cryptoAccount)? onComplete,
  }) async {
    final CryptoAccountData cryptoAccountData = state.cryptoAccount.data[index];
    cryptoAccountData.name = newAccountName;

    final cryptoAccounts = List.of(state.cryptoAccount.data);
    cryptoAccounts[index] = cryptoAccountData;

    final CryptoAccount cryptoAccount = CryptoAccount(data: cryptoAccounts);
    final String cryptoAccountString = jsonEncode(cryptoAccount.toJson());
    await secureStorageProvider.set(
      SecureStorageKeys.cryptoAccount,
      cryptoAccountString,
    );

    /// get id of current AssociatedAddres credential of this account
    final oldCredentialList = List<CredentialModel>.from(state.credentials);
    final filteredCredentialList = getCredentialsFromFilterList(
      [
        Field([r'$..type'], Filter('String', 'TezosAssociatedAddress')),
        Field(
          [r'$..associatedAddress'],
          Filter('String', cryptoAccountData.walletAddress),
        ),
      ],
      oldCredentialList,
    );

    /// update or create AssociatedAddres credential with new name
    if (filteredCredentialList.isNotEmpty) {
      final credential = await generateAssociatedWalletCredential(
        accountName: cryptoAccountData.name,
        walletAddress: cryptoAccountData.walletAddress,
        cryptoKey: cryptoAccountData.key,
        oldId: filteredCredentialList.first.id,
      );
      if (credential != null) {
        await updateCredential(credential: credential);
      }
    } else {
      final credential = await generateAssociatedWalletCredential(
        accountName: cryptoAccountData.name,
        walletAddress: cryptoAccountData.walletAddress,
        cryptoKey: cryptoAccountData.key,
      );
      if (credential != null) {
        await insertCredential(credential);
      }
    }

    emitCryptoAccount(cryptoAccount);

    onComplete?.call(cryptoAccount);
  }

  void emitCryptoAccount(CryptoAccount cryptoAccount) {
    emit(
      state.copyWith(
        status: WalletStatus.populate,
        cryptoAccount: cryptoAccount,
      ),
    );
  }

  Future deleteById({
    required CredentialModel credential,
    bool showMessage = true,
  }) async {
    emit(state.loading());
    await repository.deleteById(credential.id);
    final credentials = List.of(state.credentials)
      ..removeWhere((element) => element.id == credential.id);
    await credentialListCubit.deleteById(credential);
    emit(
      state.copyWith(
        status: WalletStatus.delete,
        credentials: credentials,
        messageHandler: showMessage
            ? ResponseMessage(
                ResponseString
                    .RESPONSE_STRING_CREDENTIAL_DETAIL_DELETE_SUCCESS_MESSAGE,
              )
            : null,
      ),
    );
  }

  Future loadAllCredentialsFromRepository() async {
    await repository.findAll(/* filters */).then((values) {
      emit(
        state.copyWith(
          status: WalletStatus.populate,
          credentials: values,
        ),
      );
    });
  }

  Future updateCredential({
    required CredentialModel credential,
    bool showMessage = true,
  }) async {
    await repository.update(credential);
    final index =
        state.credentials.indexWhere((element) => element.id == credential.id);

    final credentials = List.of(state.credentials);
    credentials[index] = credential;

    await credentialListCubit.updateCredential(credential);
    emit(
      state.copyWith(
        status: WalletStatus.update,
        credentials: credentials,
        messageHandler: showMessage
            ? ResponseMessage(
                ResponseString
                    .RESPONSE_STRING_CREDENTIAL_DETAIL_EDIT_SUCCESS_MESSAGE,
              )
            : null,
      ),
    );
  }

  Future handleUnknownRevocationStatus(CredentialModel credential) async {
    await repository.update(credential);
    final index =
        state.credentials.indexWhere((element) => element.id == credential.id);
    if (index != -1) {
      final credentials = List.of(state.credentials)
        ..removeWhere((element) => element.id == credential.id)
        ..insert(index, credential);
      emit(
        state.copyWith(
          status: WalletStatus.populate,
          credentials: credentials,
        ),
      );
    }
  }

  Future insertCredential(CredentialModel credential) async {
    /// Old EmailPass needs to be removed if currently adding new EmailPass
    /// with same email address
    if (credential
            .credentialPreview.credentialSubjectModel.credentialSubjectType ==
        CredentialSubjectType.emailPass) {
      final String? email = (credential.credentialPreview.credentialSubjectModel
              as EmailPassModel)
          .email;

      if (email != null) {
        final List<CredentialModel> allCredentials = await repository.findAll();

        for (final storedCredential in allCredentials) {
          final credentialSubjectModel =
              storedCredential.credentialPreview.credentialSubjectModel;
          if (credentialSubjectModel.credentialSubjectType ==
              CredentialSubjectType.emailPass) {
            if (email == (credentialSubjectModel as EmailPassModel).email) {
              await deleteById(
                credential: storedCredential,
                showMessage: false,
              );
              await credentialListCubit.deleteById(storedCredential);
              break;
            }
          }
        }
      }
    }
    // if same email credential is present

    await repository.insert(credential);
    final credentials = List.of(state.credentials)..add(credential);

    final CredentialCategory credentialCategory =
        credential.credentialPreview.credentialSubjectModel.credentialCategory;

    if (credentialCategory == CredentialCategory.gamingCards &&
        credentialListCubit.state.gamingCredentials.isEmpty) {
      if (!advanceSettingsCubit.state.isGamingEnabled) {
        advanceSettingsCubit.toggleGamingRadio();
      }
    }

    if (credentialCategory == CredentialCategory.communityCards &&
        credentialListCubit.state.communityCredentials.isEmpty) {
      if (!advanceSettingsCubit.state.isCommunityEnabled) {
        advanceSettingsCubit.toggleCommunityRadio();
      }
    }

    if (credentialCategory == CredentialCategory.identityCards &&
        credentialListCubit.state.identityCredentials.isEmpty) {
      if (!advanceSettingsCubit.state.isIdentityEnabled) {
        advanceSettingsCubit.toggleIdentityRadio();
      }
    }

    if (credentialCategory == CredentialCategory.passCards &&
        credentialListCubit.state.passCredentials.isEmpty) {
      if (!advanceSettingsCubit.state.isPassEnabled) {
        advanceSettingsCubit.togglePassRadio();
      }
    }

    if (credentialCategory == CredentialCategory.blockchainAccountsCards &&
        credentialListCubit.state.blockchainAccountsCredentials.isEmpty) {
      if (!advanceSettingsCubit.state.isBlockchainAccountsEnabled) {
        advanceSettingsCubit.toggleBlockchainAccountsRadio();
      }
    }

    if (credentialCategory == CredentialCategory.othersCards &&
        credentialListCubit.state.othersCredentials.isEmpty) {
      if (!advanceSettingsCubit.state.isOtherEnabled) {
        advanceSettingsCubit.toggleOtherRadio();
      }
    }

    await credentialListCubit.insertCredential(
      credential: credential,
    );

    emit(
      state.copyWith(
        status: WalletStatus.insert,
        credentials: credentials,
        messageHandler: ResponseMessage(
          ResponseString.RESPONSE_STRING_CREDENTIAL_ADDED_MESSAGE,
        ),
      ),
    );
  }

  Future resetWallet() async {
    /// reward operations id in all accounts
    for (final cryptoAccountData in state.cryptoAccount.data) {
      await secureStorageProvider.delete(
        SecureStorageKeys.lastNotifiedXTZRewardId +
            cryptoAccountData.walletAddress,
      );
      await secureStorageProvider.delete(
        SecureStorageKeys.lastNotifiedUNORewardId +
            cryptoAccountData.walletAddress,
      );
    }

    /// ssi
    await secureStorageProvider.delete(SecureStorageKeys.ssiMnemonic);
    await secureStorageProvider.delete(SecureStorageKeys.ssiKey);

    /// did
    await secureStorageProvider.delete(SecureStorageKeys.did);
    await secureStorageProvider.delete(SecureStorageKeys.didMethod);
    await secureStorageProvider.delete(SecureStorageKeys.didMethodName);
    await secureStorageProvider.delete(SecureStorageKeys.verificationMethod);

    /// crypto
    await secureStorageProvider.delete(SecureStorageKeys.cryptoAccount);
    await secureStorageProvider.delete(SecureStorageKeys.derivePathIndex);
    await secureStorageProvider.delete(SecureStorageKeys.currentTezosIndex);
    await secureStorageProvider.delete(SecureStorageKeys.currentEthereumIndex);
    await secureStorageProvider.delete(SecureStorageKeys.data);

    /// credentials
    await repository.deleteAll();

    /// passBase
    await secureStorageProvider.delete(SecureStorageKeys.passBaseStatus);
    await secureStorageProvider
        .delete(SecureStorageKeys.passBaseVerificationDate);
    await secureStorageProvider.delete(SecureStorageKeys.preAuthorizedCode);

    /// user data
    await profileCubit.resetProfile();
    await secureStorageProvider.delete(SecureStorageKeys.pinCode);

    /// clear app states
    homeCubit.emitHasNoWallet();
    await credentialListCubit.clearHomeCredentials();
    emit(
      state.copyWith(
        status: WalletStatus.reset,
        credentials: [],
        cryptoAccount: CryptoAccount(data: const []),
        currentCryptoIndex: null,
      ),
    );
    emit(state.copyWith(status: WalletStatus.init));
  }

  Future<void> recoverWallet(List<CredentialModel> credentials) async {
    await repository.deleteAll();
    for (final credential in credentials) {
      await repository.insert(credential);
    }
    homeCubit.emitHasNoWallet();
    emit(state.copyWith(status: WalletStatus.init, credentials: credentials));
  }

  ///helper function to generate TezosAssociatedAddressCredential
  Future<CredentialModel?> generateAssociatedWalletCredential({
    required String accountName,
    required String walletAddress,
    required String cryptoKey,
    String? oldId,
  }) async {
    final log = getLogger('WalletCubit - generateAssociatedWalletCredential');
    try {
      const didMethod = AltMeStrings.defaultDIDMethod;
      final didSsi = didCubit.state.did!;
      final did = didKitProvider.keyToDID(didMethod, cryptoKey);

      final verificationMethod =
          await didKitProvider.keyToVerificationMethod(didMethod, cryptoKey);

      final options = {
        'proofPurpose': 'assertionMethod',
        'verificationMethod': verificationMethod
      };
      final verifyOptions = {'proofPurpose': 'assertionMethod'};
      final id = 'urn:uuid:${const Uuid().v4()}';
      final formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
      final issuanceDate = '${formatter.format(DateTime.now())}Z';

      final credentialManifest = CredentialManifest.fromJson(
        ConstantsJson.tezosAssociatedAddressCredentialManifestJson,
      );

      final tezosAssociatedAddressModel = TezosAssociatedAddressModel(
        id: didSsi,
        accountName: accountName,
        associatedAddress: walletAddress,
        type: 'TezosAssociatedAddress',
      );

      final tezosAssociatedAddressCredential = TezosAssociatedAddressCredential(
        id: id,
        issuer: did,
        issuanceDate: issuanceDate,
        credentialSubjectModel: tezosAssociatedAddressModel,
      );
      final vc = await didKitProvider.issueCredential(
        jsonEncode(tezosAssociatedAddressCredential.toJson()),
        jsonEncode(options),
        cryptoKey,
      );
      final result =
          await didKitProvider.verifyCredential(vc, jsonEncode(verifyOptions));
      final jsonVerification = jsonDecode(result) as Map<String, dynamic>;

      if ((jsonVerification['warnings'] as List<dynamic>).isNotEmpty) {
        log.w(
          'credential verification return warnings',
          jsonVerification['warnings'],
        );
      }

      if ((jsonVerification['errors'] as List<dynamic>).isNotEmpty) {
        log.e('failed to verify credential, ${jsonVerification['errors']}');
        if (jsonVerification['errors'][0] != 'No applicable proof') {
          throw ResponseMessage(
            ResponseString
                .RESPONSE_STRING_FAILED_TO_VERIFY_SELF_ISSUED_CREDENTIAL,
          );
        } else {
          return _createCredential(vc, oldId, credentialManifest);
        }
      } else {
        return _createCredential(vc, oldId, credentialManifest);
      }
    } catch (e, s) {
      getLogger(runtimeType.toString())
          .e('something went wrong e: $e, stackTrace: $s', e, s);
      return null;
    }
  }

  Future<CredentialModel> _createCredential(
    String vc,
    String? oldId,
    CredentialManifest credentialManifest,
  ) async {
    final jsonCredential = jsonDecode(vc) as Map<String, dynamic>;
    final id = oldId ?? 'urn:uuid:${const Uuid().v4()}';
    return CredentialModel(
      id: id,
      image: 'image',
      data: jsonCredential,
      display: Display.emptyDisplay()..toJson(),
      shareLink: '',
      credentialPreview: Credential.fromJson(jsonCredential),
      credentialManifest: credentialManifest,
      activities: [Activity(acquisitionAt: DateTime.now())],
    );
  }
}
