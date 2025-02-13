import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/polygon_id/cubit/polygon_id_cubit.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifiableDataRegistryPage extends StatelessWidget {
  const VerifiableDataRegistryPage({super.key});

  static Route<dynamic> route() => MaterialPageRoute<void>(
        builder: (_) => const VerifiableDataRegistryPage(),
        settings: const RouteSettings(name: '/VerifiableDataRegistryPage'),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BasePage(
      title: l10n.verifiableDataRegistry,
      titleAlignment: Alignment.topCenter,
      titleLeading: const BackLeadingButton(),
      scrollView: true,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: context.read<ProfileCubit>(),
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
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  l10n.chooseIssuerRegistryDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall3,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: Sizes.spaceSmall),
                child: Text(
                  l10n.polygon,
                  style: Theme.of(context).textTheme.subtitle3,
                ),
              ),
              GroupedSection(
                children: [
                  IssuerVerifierSelector(
                    title: PolygonIdNetwork.PolygonMainnet.name,
                    isChecked: state.model.polygonIdNetwork
                        .contains(PolygonIdNetwork.PolygonMainnet.toString()),
                    onTap: () {
                      context.read<ProfileCubit>().updatePolygonIdNetwork(
                            polygonIdCubit: context.read<PolygonIdCubit>(),
                            polygonIdNetwork: PolygonIdNetwork.PolygonMainnet,
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.spaceSmall,
                    ),
                    child: Divider(
                      color: Theme.of(context).colorScheme.borderColor,
                    ),
                  ),
                  IssuerVerifierSelector(
                    title: PolygonIdNetwork.PolygonMumbai.name,
                    isChecked: state.model.polygonIdNetwork
                        .contains(PolygonIdNetwork.PolygonMumbai.toString()),
                    onTap: () {
                      context.read<ProfileCubit>().updatePolygonIdNetwork(
                            polygonIdCubit: context.read<PolygonIdCubit>(),
                            polygonIdNetwork: PolygonIdNetwork.PolygonMumbai,
                          );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: Sizes.spaceSmall),
                child: Text(
                  l10n.ebsi,
                  style: Theme.of(context).textTheme.subtitle3,
                ),
              ),
              const GroupedSection(
                children: [
                  IssuerVerifierSelector(
                    title: 'EBSI',
                    isChecked: true,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
