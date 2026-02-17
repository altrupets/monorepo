import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';

part 'search_organizations_input.freezed.dart';
part 'search_organizations_input.g.dart';

@freezed
class SearchOrganizationsInput with _$SearchOrganizationsInput {
  const factory SearchOrganizationsInput({
    String? name,
    OrganizationType? type,
    OrganizationStatus? status,
    String? country,
    String? province,
    String? canton,
  }) = _SearchOrganizationsInput;

  factory SearchOrganizationsInput.fromJson(Map<String, dynamic> json) =>
      _$SearchOrganizationsInputFromJson(json);
}
