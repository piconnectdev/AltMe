import 'package:arago_wallet/dashboard/dashboard.dart';
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
    return BlocBuilder<AdvanceSettingsCubit, AdvanceSettingsState>(
        builder: (context, advanceSettingsState) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            if (advanceSettingsState.isGamingEnabled) ...[
              GamingCredentials(credentials: state.gamingCredentials),
              const SizedBox(height: Sizes.spaceNormal),
            ],
            if (advanceSettingsState.isCommunityEnabled) ...[
              CommunityCredentials(credentials: state.communityCredentials),
              const SizedBox(height: Sizes.spaceNormal),
            ],
            if (advanceSettingsState.isIdentityEnabled) ...[
              IdentityCredentials(credentials: state.identityCredentials),
              const SizedBox(height: Sizes.spaceNormal),
            ],
            // ProofOfOwnershipCredentials is hidden. Later we will
            // give user an option to show it
            if (advanceSettingsState.isPaymentEnabled) ...[
              ProofOfOwnershipCredentials(
                credentials: state.proofOfOwnershipCredentials,
              ),
              const SizedBox(height: Sizes.spaceNormal),
            ],
            if (advanceSettingsState.isOtherEnabled) ...[
              OtherCredentials(credentials: state.othersCredentials),
              const SizedBox(height: Sizes.spaceNormal),
            ],
          ],
        ),
      );
    });
  }
}
