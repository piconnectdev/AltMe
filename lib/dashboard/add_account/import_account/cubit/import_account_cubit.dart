import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/did/did.dart';
import 'package:altme/wallet/wallet.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:did_kit/did_kit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:key_generator/key_generator.dart';

import 'package:secure_storage/secure_storage.dart';

part 'import_account_cubit.g.dart';
part 'import_account_state.dart';

class ImportAccountCubit extends Cubit<ImportAccountState> {
  ImportAccountCubit({
    required this.didKitProvider,
    required this.secureStorageProvider,
    required this.keyGenerator,
    required this.homeCubit,
    required this.didCubit,
    required this.walletCubit,
  }) : super(const ImportAccountState());

  final DIDKitProvider didKitProvider;
  final SecureStorageProvider secureStorageProvider;
  final KeyGenerator keyGenerator;
  final HomeCubit homeCubit;
  final DIDCubit didCubit;
  final WalletCubit walletCubit;

  void isMnemonicsOrKeyValid(String value) {
    //different type of tezos private keys start with 'edsk' ,
    //'pspsk' and 'p2sk;
    final bool isSecretKey = isValidPrivateKey(value);

    emit(
      state.populating(
        isTextFieldEdited: value.isNotEmpty,
        mnemonicOrKey: value,
        isMnemonicOrKeyValid:
            (bip39.validateMnemonic(value) || isSecretKey) && value.isNotEmpty,
      ),
    );
  }

  Future<void> import({
    required bool isFromOnboarding,
    String? accountName,
  }) async {
    final log = getLogger('ImportAccountCubit - import');
    emit(state.loading());
    await Future<void>.delayed(const Duration(milliseconds: 500));

    try {
      log.e('isFromOnboarding: $isFromOnboarding');
      if (isFromOnboarding) {
        /// ssi creation

        late String mnemonic;
        final isSecretKey = state.mnemonicOrKey.startsWith('edsk') ||
            state.mnemonicOrKey.startsWith('spsk') ||
            state.mnemonicOrKey.startsWith('p2sk') ||
            state.mnemonicOrKey.startsWith('0x');

        if (isSecretKey) {
          mnemonic = bip39.generateMnemonic();
        } else {
          mnemonic = state.mnemonicOrKey;
        }

        await secureStorageProvider.set(
          SecureStorageKeys.ssiMnemonic,
          mnemonic,
        );
        final ssiKey = await keyGenerator.jwkFromMnemonic(
          mnemonic: mnemonic,
          accountType: AccountType.ssi,
        );
        await secureStorageProvider.set(SecureStorageKeys.ssiKey, ssiKey);

        const didMethod = AltMeStrings.defaultDIDMethod;
        final did = didKitProvider.keyToDID(didMethod, ssiKey);
        final verificationMethod =
            await didKitProvider.keyToVerificationMethod(didMethod, ssiKey);

        await didCubit.set(
          did: did,
          didMethod: didMethod,
          didMethodName: AltMeStrings.defaultDIDMethodName,
          verificationMethod: verificationMethod,
        );
      }

      /// crypto wallet
      await walletCubit.createCryptoWallet(
        accountName: accountName,
        mnemonicOrKey: state.mnemonicOrKey,
        isImported: !isFromOnboarding,
        // TODO(all): dynamic the blockchain type depends on selected type
        blockchainType: BlockchainType.tezos,
        onComplete: ({
          required CryptoAccount cryptoAccount,
          required MessageHandler messageHandler,
        }) async {
          emit(
            state.success(
              messageHandler: ResponseMessage(
                ResponseString.RESPONSE_STRING_CRYPTO_ACCOUNT_ADDED,
              ),
            ),
          );
        },
      );

      await homeCubit.emitHasWallet();
      emit(state.success());
    } catch (error, stack) {
      log.e('error: $error,stack: $stack');
      log.e('something went wrong when generating a key', error);
      emit(
        state.error(
          messageHandler: ResponseMessage(
            ResponseString.RESPONSE_STRING_ERROR_GENERATING_KEY,
          ),
        ),
      );
    }
  }
}
