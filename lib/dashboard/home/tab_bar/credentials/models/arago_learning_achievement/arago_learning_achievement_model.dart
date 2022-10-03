import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/dashboard/dashboard.dart';
import 'package:arago_wallet/dashboard/home/tab_bar/credentials/models/learning_achievement/has_credential.dart';
import 'package:json_annotation/json_annotation.dart';

part 'arago_learning_achievement_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class AragoLearningAchievementModel extends CredentialSubjectModel {
  AragoLearningAchievementModel({
    String? id,
    String? type,
    this.familyName,
    this.givenName,
    this.email,
    this.birthDate,
    this.hasCredential,
    Author? issuedBy,
  }) : super(
          id: id,
          type: type,
          issuedBy: issuedBy,
          credentialSubjectType: CredentialSubjectType.learningAchievement,
          credentialCategory: CredentialCategory.identityCards,
        );

  factory AragoLearningAchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AragoLearningAchievementModelFromJson(json);

  @JsonKey(defaultValue: '')
  String? familyName;
  @JsonKey(defaultValue: '')
  String? givenName;
  @JsonKey(defaultValue: '')
  String? email;
  @JsonKey(defaultValue: '')
  String? birthDate;
  HasCredential? hasCredential;

  @override
  Map<String, dynamic> toJson() => _$AragoLearningAchievementModelToJson(this);
}
