import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:altme/l10n/l10n.dart';
import 'package:flutter/material.dart';

class DiscoverDetailsPage extends StatelessWidget {
  const DiscoverDetailsPage({
    super.key,
    required this.dummyCredential,
    required this.onCallBack,
    required this.buttonText,
  });

  final DiscoverDummyCredential dummyCredential;
  final VoidCallback onCallBack;
  final String buttonText;

  static Route<dynamic> route({
    required DiscoverDummyCredential dummyCredential,
    required VoidCallback onCallBack,
    required String buttonText,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) => DiscoverDetailsPage(
        dummyCredential: dummyCredential,
        onCallBack: onCallBack,
        buttonText: buttonText,
      ),
      settings: const RouteSettings(name: '/DiscoverDetailsPages'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DiscoverDetailsView(
      dummyCredential: dummyCredential,
      onCallBack: onCallBack,
      buttonText: buttonText,
    );
  }
}

class DiscoverDetailsView extends StatelessWidget {
  const DiscoverDetailsView({
    super.key,
    required this.dummyCredential,
    required this.onCallBack,
    required this.buttonText,
  });

  final DiscoverDummyCredential dummyCredential;
  final VoidCallback onCallBack;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BasePage(
      title: l10n.cardDetails,
      scrollView: false,
      titleAlignment: Alignment.topCenter,
      titleLeading: const BackLeadingButton(),
      body: BackgroundCard(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: AspectRatio(
                        aspectRatio: Sizes.credentialAspectRatio,
                        child: CredentialImage(image: dummyCredential.image!),
                      ),
                    ),
                    DetailFields(dummyCredential: dummyCredential),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      navigation: Padding(
        padding: const EdgeInsets.all(
          Sizes.spaceSmall,
        ),
        child: MyGradientButton(
          onPressed: dummyCredential.credentialSubjectType.isDisabled
              ? null
              : onCallBack,
          text: buttonText,
        ),
      ),
    );
  }
}

class DetailFields extends StatelessWidget {
  const DetailFields({
    super.key,
    required this.dummyCredential,
  });

  final DiscoverDummyCredential dummyCredential;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (dummyCredential.credentialSubjectType.isDisabled) {
      return DiscoverDynamicDetial(
        title: l10n.credentialManifestDescription,
        value: l10n.soonCardDescription,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dummyCredential.websiteLink != null)
          DiscoverDynamicDetial(
            title: l10n.website,
            value: dummyCredential.websiteLink!,
            format: AltMeStrings.uri,
          ),
        if (dummyCredential.longDescription != null)
          DiscoverDynamicDetial(
            title: dummyCredential.credentialSubjectType.title,
            value: dummyCredential.whyGetThisCard!.getMessage(
              context,
              dummyCredential.longDescription!,
            ),
          ),
        if (dummyCredential.whyGetThisCard != null)
          DiscoverDynamicDetial(
            title: l10n.whyGetThisCard,
            value: dummyCredential.whyGetThisCard!.getMessage(
              context,
              dummyCredential.whyGetThisCard!,
            ),
          ),
        if (dummyCredential.expirationDateDetails != null)
          DiscoverDynamicDetial(
            title: l10n.expirationDate,
            value: dummyCredential.expirationDateDetails!.getMessage(
              context,
              dummyCredential.expirationDateDetails!,
            ),
          ),
        if (dummyCredential.howToGetIt != null)
          DiscoverDynamicDetial(
            title: l10n.howToGetIt,
            value: dummyCredential.howToGetIt!.getMessage(
              context,
              dummyCredential.howToGetIt!,
            ),
          ),
      ],
    );
  }
}
