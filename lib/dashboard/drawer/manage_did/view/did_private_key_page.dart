import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_application/secure_application.dart';
import 'package:secure_storage/secure_storage.dart';

class DIDPrivateKeyPage extends StatefulWidget {
  const DIDPrivateKeyPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DIDPrivateKeyCubit>(
        create: (_) =>
            DIDPrivateKeyCubit(secureStorageProvider: getSecureStorage),
        child: const DIDPrivateKeyPage(),
      ),
      settings: const RouteSettings(name: '/DIDPrivateKeyPage'),
    );
  }

  @override
  State<DIDPrivateKeyPage> createState() => _DIDPrivateKeyPageState();
}

class _DIDPrivateKeyPageState extends State<DIDPrivateKeyPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SecureApplicationController secureApplicationController =
      SecureApplicationController(
    SecureApplicationState(secured: true, authenticated: true),
  );

  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      secureApplicationController.lock();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => context.read<DIDPrivateKeyCubit>().initialize());
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    final Tween<double> _rotationTween = Tween(begin: 20, end: 0);

    animation = _rotationTween.animate(animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
        }
      });
    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            title: l10n.decentralizedIDKey,
            titleAlignment: Alignment.topCenter,
            titleLeading: const BackLeadingButton(),
            titleTrailing: AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                return Text(
                  timeFormatter(timeInSecond: animation.value.toInt()),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
            body: BackgroundCard(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    l10n.didPrivateKey,
                    style: Theme.of(context).textTheme.title,
                  ),
                  const SizedBox(
                    height: Sizes.spaceNormal,
                  ),
                  BlocBuilder<DIDPrivateKeyCubit, String>(
                    builder: (context, state) {
                      return Text(
                        state,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      );
                    },
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(Sizes.spaceXLarge),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       CopyButton(
                  //         onTap: () async {
                  //           await Clipboard.setData(
                  //             ClipboardData(
                  //               text: context.read<DIDPrivateKeyCubit>().state,
                  //             ),
                  //           );
                  //           AlertMessage.showStateMessage(
                  //             context: context,
                  //             stateMessage: StateMessage.success(
                  //               stringMessage: l10n.copySecretKeyToClipboard,
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //       // const SizedBox(
                  //       //   width: Sizes.spaceXLarge,
                  //       // ),
                  //       //const ExportButton(),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
