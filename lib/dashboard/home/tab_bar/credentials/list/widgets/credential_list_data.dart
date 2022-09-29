import 'package:altme/app/shared/constants/sizes.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CredentialListData extends StatelessWidget {
  const CredentialListData({
    Key? key,
    required this.state,
    required this.onRefresh,
  }) : super(key: key);

  final CredentialListState state;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AdvanceSettingsCubit, AdvanceSettingsState>(
      builder: (context, advanceSettingsState) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              if (advanceSettingsState.isGamingEnabled) ...[
                /// Gaming Credentials
                HomeCredentialWidget(
                  title: l10n.gamingCards,
                  credentials: state.gamingCredentials,
                ),
                const SizedBox(height: Sizes.spaceNormal),
              ],
              if (advanceSettingsState.isCommunityEnabled) ...[
                /// Community Credentials
                HomeCredentialWidget(
                  title: l10n.communityCards,
                  credentials: state.communityCredentials,
                ),
                const SizedBox(height: Sizes.spaceNormal),
              ],
              if (advanceSettingsState.isIdentityEnabled) ...[
                /// Identity Credentials
                HomeCredentialWidget(
                  title: l10n.identityCards,
                  credentials: state.identityCredentials,
                ),
                const SizedBox(height: Sizes.spaceNormal),
              ],
              // ProofOfOwnershipCredentials is hidden. Later we will
              // give user an option to show it
              if (advanceSettingsState.isPaymentEnabled) ...[
                /// ProofOfOwnership Credentials
                HomeCredentialWidget(
                  title: l10n.proofOfOwnership,
                  credentials: state.proofOfOwnershipCredentials,
                ),
                const SizedBox(height: Sizes.spaceNormal),
              ],
              if (advanceSettingsState.isOtherEnabled) ...[
                /// Other Credentials
                HomeCredentialWidget(
                  title: l10n.otherCards,
                  credentials: state.othersCredentials,
                ),
                const SizedBox(height: Sizes.spaceNormal),
              ],
            ],
          ),
        );
      },
    );
  }
}
