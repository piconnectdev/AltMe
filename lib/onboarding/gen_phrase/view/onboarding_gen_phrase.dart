import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/did/did.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/onboarding/onboarding.dart';
import 'package:altme/theme/theme.dart';
import 'package:altme/wallet/cubit/wallet_cubit.dart';
//import 'package:did_kit/did_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:key_generator/key_generator.dart';
import 'package:secure_application/secure_application.dart';
import 'package:secure_storage/secure_storage.dart';

class OnBoardingGenPhrasePage extends StatelessWidget {
  const OnBoardingGenPhrasePage({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute<void>(
        builder: (context) => const OnBoardingGenPhrasePage(),
        settings: const RouteSettings(name: '/onBoardingGenPhrasePage'),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnBoardingGenPhraseCubit(
        secureStorageProvider: getSecureStorage,
        didCubit: context.read<DIDCubit>(),
        //didKitProvider: DIDKitProvider(),
        keyGenerator: KeyGenerator(),
        homeCubit: context.read<HomeCubit>(),
        walletCubit: context.read<WalletCubit>(),
      ),
      child: const OnBoardingGenPhraseView(),
    );
  }
}

class OnBoardingGenPhraseView extends StatefulWidget {
  const OnBoardingGenPhraseView({Key? key}) : super(key: key);

  @override
  State<OnBoardingGenPhraseView> createState() =>
      _OnBoardingGenPhraseViewState();
}

class _OnBoardingGenPhraseViewState extends State<OnBoardingGenPhraseView>
    with WidgetsBindingObserver {
  final SecureApplicationController secureApplicationController =
      SecureApplicationController(
    SecureApplicationState(secured: true, authenticated: true),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => context.read<DIDPrivateKeyCubit>().initialize());
    disableScreenshot();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      secureApplicationController.lock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    enableScreenshot();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<OnBoardingGenPhraseCubit, OnBoardingGenPhraseState>(
      listener: (context, state) {
        if (state.status == AppStatus.loading) {
          LoadingView().show(context: context);
        } else {
          LoadingView().hide();
        }

        if (state.message != null) {
          AlertMessage.showStateMessage(
            context: context,
            stateMessage: state.message!,
          );
        }
        if (state.status == AppStatus.success) {
          Navigator.pushAndRemoveUntil<void>(
            context,
            WalletReadyPage.route(),
            (Route<dynamic> route) => route.isFirst,
          );
        }
      },
      builder: (context, state) {
        return SecureApplication(
          nativeRemoveDelay: 800,
          autoUnlockNative: true,
          secureApplicationController: secureApplicationController,
          onNeedUnlock: (secureApplicationController) async {
            /// need unlock maybe use biometric to confirm and then sercure.unlock()
            /// or you can use the lockedBuilder

            secureApplicationController!.authSuccess(unlock: true);
            return SecureApplicationAuthenticationStatus.SUCCESS;
            //return null;
          },
          child: Builder(builder: (context) {
            return SecureGate(
              blurr: Parameters.blurr,
              opacity: Parameters.opacity,
              lockedBuilder: (context, secureNotifier) => Container(),
              child: BasePage(
                scrollView: false,
                useSafeArea: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: Sizes.spaceXSmall),
                titleLeading: const BackLeadingButton(),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const MStepper(
                              step: 3,
                              totalStep: 3,
                            ),
                            const SizedBox(
                              height: Sizes.spaceNormal,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.spaceNormal,
                              ),
                              child: Text(
                                l10n.onboardingPleaseStoreMessage,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                            const SizedBox(height: Sizes.spaceNormal),
                            MnemonicDisplay(mnemonic: state.mnemonic),
                            // const SizedBox(
                            //   height: Sizes.spaceSmall,
                            // ),
                            // TextButton(
                            //   onPressed: () {
                            //     Clipboard.setData(
                            //       ClipboardData(
                            //         text: state.mnemonic.join(' '),
                            //       ),
                            //     );
                            //   },
                            //   child: Text(
                            //     l10n.copyToClipboard,
                            //     style: Theme.of(context).textTheme.copyToClipBoard,
                            //   ),
                            // ),
                            const SizedBox(height: Sizes.spaceLarge),
                            Text(
                              l10n.onboardingAltmeMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .genPhraseSubmessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(
                        Sizes.spaceNormal,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: state.isTicked,
                              fillColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              onChanged: (newValue) => context
                                  .read<OnBoardingGenPhraseCubit>()
                                  .switchTick(),
                            ),
                          ),
                          const SizedBox(
                            width: Sizes.spaceXSmall,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<OnBoardingGenPhraseCubit>()
                                    .switchTick();
                              },
                              child: MyText(
                                l10n.onboardingWroteDownMessage,
                                style: Theme.of(context)
                                    .textTheme
                                    .onBoardingCheckMessage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                navigation: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.spaceSmall,
                      vertical: Sizes.spaceSmall,
                    ),
                    child: MyGradientButton(
                      text: l10n.onBoardingGenPhraseButton,
                      verticalSpacing: 18,
                      onPressed: state.isTicked
                          ? () async {
                              await context
                                  .read<OnBoardingGenPhraseCubit>()
                                  .generateSSIAndCryptoAccount(state.mnemonic);
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
