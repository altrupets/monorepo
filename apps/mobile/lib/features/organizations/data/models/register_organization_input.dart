import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';

part 'register_organization_input.freezed.dart';
part 'register_organization_input.g.dart';

@freezed
class RegisterOrganizationInput with _$RegisterOrganizationInput {
  const factory RegisterOrganizationInput({
    required String name,
    required OrganizationType type,
    String? legalId,
    String? description,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? country,
    String? province,
    String? canton,
    String? district,
    String? legalDocumentationBase64,
    String? financialStatementsBase64,
    int? maxCapacity,
  }) = _RegisterOrganizationInput;

  factory RegisterOrganizationInput.fromJson(Map<String, dynamic> json) =>
      _$RegisterOrganizationInputFromJson(json);
}
