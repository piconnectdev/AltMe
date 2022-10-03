import 'package:arago_wallet/app/app.dart';
import 'package:arago_wallet/dashboard/dashboard.dart';
import 'package:arago_wallet/dashboard/home/tab_bar/credentials/models/tezotopia_voucher/offers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tezotopia_membership_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TezotopiaMembershipModel extends CredentialSubjectModel {
  TezotopiaMembershipModel({
    this.expires,
    this.offers,
    String? id,
    String? type,
    Author? issuedBy,
  }) : super(
          id: id,
          type: type,
          issuedBy: issuedBy,
          credentialSubjectType: CredentialSubjectType.tezotopiaMembership,
          credentialCategory: CredentialCategory.gamingCards,
        );

  factory TezotopiaMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$TezotopiaMembershipModelFromJson(json);

  @JsonKey(defaultValue: '')
  final String? expires;
  final Offers? offers;

  @override
  Map<String, dynamic> toJson() => _$TezotopiaMembershipModelToJson(this);
}
