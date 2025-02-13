import 'package:altme/app/app.dart';
import 'package:altme/chat_room/chat_room.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_storage/secure_storage.dart';

class HomeCredentialItem extends StatelessWidget {
  const HomeCredentialItem({
    super.key,
    required this.credentialModel,
  });

  final CredentialModel credentialModel;

  @override
  Widget build(BuildContext context) {
    if (credentialModel.data['credentialSubject']?['chatSupport'] != null) {
      final cardName = credentialModel
          .credentialPreview.credentialSubjectModel.credentialSubjectType.name;

      final cardChatSupportCubit = CardChatSupportCubit(
        secureStorageProvider: getSecureStorage,
        matrixChat: MatrixChatImpl(),
        invites: [
          credentialModel.data['credentialSubject']?['chatSupport'] as String
        ],
        storageKey: '$cardName-${SecureStorageKeys.cardChatSupportRoomId}',
        roomNamePrefix: cardName,
      );

      return BlocProvider(
        create: (_) => cardChatSupportCubit,
        child: StreamBuilder(
          stream: cardChatSupportCubit.unreadMessageCountStream,
          initialData: cardChatSupportCubit.unreadMessageCount,
          builder: (context, snapShot) {
            return CredentialsListPageItem(
              credentialModel: credentialModel,
              badgeCount: snapShot.data ?? 0,
              onTap: () {
                Navigator.of(context).push<void>(
                  CredentialsDetailsPage.route(
                    credentialModel: credentialModel,
                    cardChatSupportCubit: cardChatSupportCubit,
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      return CredentialsListPageItem(
        credentialModel: credentialModel,
        onTap: () {
          Navigator.of(context).push<void>(
            CredentialsDetailsPage.route(credentialModel: credentialModel),
          );
        },
      );
    }
  }
}
