import 'package:json_annotation/json_annotation.dart';

part 'wallet_lookup_response.g.dart';

@JsonSerializable()
class WalletLookupResponse {
  final String userId;
  final String email;
  final String status;
  final String userStage;
  final String? firstName;
  final String? lastName;
  final String? displayName;

  WalletLookupResponse({
    required this.userId,
    required this.email,
    required this.status,
    required this.userStage,
    this.firstName,
    this.lastName,
    this.displayName,
  });

  /// Returns the best available name for display
  /// Priority: displayName > firstName + lastName > email
  String get bestDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (firstName != null && firstName!.isNotEmpty && 
        lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName!;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      return lastName!;
    }
    return email;
  }

  factory WalletLookupResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletLookupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletLookupResponseToJson(this);
}
