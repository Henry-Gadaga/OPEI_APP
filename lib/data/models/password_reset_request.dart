import 'package:json_annotation/json_annotation.dart';

part 'password_reset_request.g.dart';

@JsonSerializable()
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordDto {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);
}
