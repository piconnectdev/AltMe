import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/l10n/l10n.dart';
import 'package:arago_wallet/theme/theme.dart';
import 'package:flutter/material.dart';

class DisplayIssuanceDateWidget extends StatelessWidget {
  const DisplayIssuanceDateWidget({
    this.issuanceDate,
    this.textColor,
    Key? key,
  }) : super(key: key);
  final String? issuanceDate;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (issuanceDate != null) {
      return Row(
        children: [
          Expanded(
            flex: 6,
            child: MyText(
              '${l10n.issuanceDate}: ',
              style: textColor == null
                  ? Theme.of(context).textTheme.credentialFieldTitle
                  : Theme.of(context)
                      .textTheme
                      .credentialFieldTitle
                      .copyWith(color: textColor),
            ),
          ),
          Expanded(
            flex: 4,
            child: MyText(
              UiDate.formatStringDate(issuanceDate!),
              style: textColor == null
                  ? Theme.of(context)
                      .textTheme
                      .credentialFieldTitle
                      .copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context)
                      .textTheme
                      .credentialFieldTitle
                      .copyWith(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
