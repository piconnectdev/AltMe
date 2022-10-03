import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/l10n/l10n.dart';
import 'package:arago_wallet/theme/theme.dart';
import 'package:flutter/material.dart';

class TransactionDoneDialog extends StatelessWidget {
  const TransactionDoneDialog._({
    Key? key,
    required this.amountAndSymbol,
    this.onDoneButtonClick,
  }) : super(key: key);

  final String amountAndSymbol;
  final VoidCallback? onDoneButtonClick;

  static Future<void> show({
    required BuildContext context,
    required String amountAndSymbol,
    VoidCallback? onDoneButtonClick,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TransactionDoneDialog._(
        amountAndSymbol: amountAndSymbol,
        onDoneButtonClick: onDoneButtonClick,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Sizes.spaceNormal,
        vertical: Sizes.spaceSmall,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Sizes.spaceSmall),
            Image.asset(
              IconStrings.bigCheckCircle,
              height: Sizes.icon4x,
              width: Sizes.icon4x,
            ),
            const SizedBox(height: Sizes.spaceNormal),
            Text(
              '$amountAndSymbol ${l10n.sent.toLowerCase()}',
              style: Theme.of(context).textTheme.defaultDialogTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceSmall),
            Text(
              l10n.transactionDoneDialogDescription,
              style: Theme.of(context).textTheme.defaultDialogBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceSmall),
            MyElevatedButton(
              text: l10n.done,
              verticalSpacing: 18,
              fontSize: 18,
              borderRadius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.of(context).pop();
                onDoneButtonClick?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
