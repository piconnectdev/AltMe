import 'package:altme/app/app.dart';
import 'package:altme/dashboard/dashboard.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gender_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GenderModel extends CredentialSubjectModel {
  GenderModel({
    this.expires,
    this.gender,
    String? id,
    String? type,
    Author? issuedBy,
  }) : super(
          id: id,
          type: type,
          issuedBy: issuedBy,
          credentialSubjectType: CredentialSubjectType.gender,
          credentialCategory: CredentialCategory.identityCards,
        );

  factory GenderModel.fromJson(Map<String, dynamic> json) =>
      _$GenderModelFromJson(json);

  @JsonKey(defaultValue: '')
  final String? expires;
  @JsonKey(defaultValue: '')
  final String? gender;

  @override
  Map<String, dynamic> toJson() => _$GenderModelToJson(this);
}
