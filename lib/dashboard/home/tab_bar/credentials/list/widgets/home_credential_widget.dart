import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:altme/theme/theme.dart';
import 'package:flutter/material.dart';

class HomeCredentialWidget extends StatelessWidget {
  const HomeCredentialWidget({
    Key? key,
    required this.credentials,
    required this.title,
    required this.categorySubtitle,
    this.showAddOption = false,
    this.fromDiscover = false,
  }) : super(key: key);

  final List<HomeCredential> credentials;
  final String title;
  final String categorySubtitle;
  final bool showAddOption;
  final bool fromDiscover;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${fromDiscover ? l10n.get : l10n.my} ${title.toLowerCase()}',
          style: Theme.of(context).textTheme.credentialCategoryTitle,
        ),
        const SizedBox(
          height: 4,
        ),
        Flexible(
          child: MyText(
            categorySubtitle,
            maxLines: 3,
            style: Theme.of(context).textTheme.credentialCategorySubTitle,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: Sizes.homeCredentialRatio,
          ),
          itemCount: credentials.length + (showAddOption ? 1 : 0),
          itemBuilder: (_, index) {
            if (showAddOption && index == credentials.length) {
              return const AddCredentialButton();
            } else {
              return HomeCredentialItem(
                homeCredential: credentials[index],
                fromDiscover: fromDiscover,
              );
            }
          },
        ),
      ],
    );
  }
}
