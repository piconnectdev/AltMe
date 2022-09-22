part of 'credential_subject_type.dart';

extension CredentialSubjectTypeExtension on CredentialSubjectType {
  Color backgroundColor(CredentialModel credentialModel) {
    Color _backgroundColor;
    if (credentialModel.display.backgroundColor != '') {
      _backgroundColor = Color(
        int.parse('FF${credentialModel.display.backgroundColor}', radix: 16),
      );
    } else {
      _backgroundColor = defaultBackgroundColor();
    }
    return _backgroundColor;
  }

  Color defaultBackgroundColor() {
    switch (this) {
      case CredentialSubjectType.tezotopiaMembership:
        return const Color(0xff273496);
      case CredentialSubjectType.nationality:
        return const Color(0xff273496);
      case CredentialSubjectType.gender:
        return const Color(0xff8C0D8E);
      case CredentialSubjectType.tezosAssociatedWallet:
        return const Color(0xffFE7400);
      case CredentialSubjectType.residentCard:
        return Colors.white;
      case CredentialSubjectType.selfIssued:
        return const Color(0xffEFF0F6);
      case CredentialSubjectType.identityPass:
        return const Color(0xffCAFFBF);
      case CredentialSubjectType.identityCard:
        return const Color(0xff2596be);
      case CredentialSubjectType.voucher:
        return const Color(0xffCAFFBF);
      case CredentialSubjectType.loyaltyCard:
        return const Color(0xffCAFFBF);
      case CredentialSubjectType.over18:
        return const Color(0xffCAFFBF);
      case CredentialSubjectType.professionalStudentCard:
        return const Color(0xffCAFFBF);
      case CredentialSubjectType.certificateOfEmployment:
        return const Color(0xFF9BF6FF);
      case CredentialSubjectType.emailPass:
        return const Color(0xFFffD6A5);
      case CredentialSubjectType.ageRange:
        return const Color(0xFFffC6B5);
      case CredentialSubjectType.phonePass:
        return const Color(0xFFffD6A5);
      case CredentialSubjectType.professionalExperienceAssessment:
        return const Color(0xFFFFADAD);
      case CredentialSubjectType.professionalSkillAssessment:
        return const Color(0xffCAFFBF);
      case CredentialSubjectType.learningAchievement:
        return const Color(0xFFFFADAD);
      case CredentialSubjectType.ecole42LearningAchievement:
        return const Color(0xFFffD6A5);
      case CredentialSubjectType.studentCard:
        return const Color(0xFFffD6A5);
      case CredentialSubjectType.tezVoucher:
        return const Color(0xff7a29de);
      case CredentialSubjectType.talaoCommunityCard:
        return const Color(0xff4700D8);
      case CredentialSubjectType.defaultCredential:
        return Colors.white;
    }
  }

  IconData iconData() {
    switch (this) {
      case CredentialSubjectType.nationality:
        return Icons.supervised_user_circle_sharp;
      case CredentialSubjectType.tezotopiaMembership:
        return Icons.supervised_user_circle_sharp;
      case CredentialSubjectType.gender:
        return Icons.supervised_user_circle_rounded;
      case CredentialSubjectType.tezosAssociatedWallet:
        return Icons.account_balance_wallet;
      case CredentialSubjectType.residentCard:
        return Icons.home;
      case CredentialSubjectType.selfIssued:
        return Icons.perm_identity;
      case CredentialSubjectType.identityPass:
        return Icons.perm_identity;
      case CredentialSubjectType.identityCard:
        return Icons.perm_identity;
      case CredentialSubjectType.loyaltyCard:
        return Icons.loyalty;
      case CredentialSubjectType.over18:
        return Icons.accessible_rounded;
      case CredentialSubjectType.professionalStudentCard:
        return Icons.perm_identity;
      case CredentialSubjectType.certificateOfEmployment:
        return Icons.work;
      case CredentialSubjectType.emailPass:
        return Icons.mail;
      case CredentialSubjectType.ageRange:
        return Icons.boy;
      case CredentialSubjectType.phonePass:
        return Icons.phone;
      case CredentialSubjectType.professionalExperienceAssessment:
        return Icons.add_road_outlined;
      case CredentialSubjectType.professionalSkillAssessment:
        return Icons.assessment_outlined;
      case CredentialSubjectType.learningAchievement:
        return Icons.star_rate_outlined;
      case CredentialSubjectType.ecole42LearningAchievement:
        return Icons.perm_identity;
      case CredentialSubjectType.studentCard:
        return Icons.perm_identity;
      case CredentialSubjectType.voucher:
        return Icons.gamepad;
      case CredentialSubjectType.tezVoucher:
        return Icons.gamepad;
      case CredentialSubjectType.talaoCommunityCard:
        return Icons.perm_identity;
      case CredentialSubjectType.defaultCredential:
        return Icons.fact_check_outlined;
    }
  }
}
