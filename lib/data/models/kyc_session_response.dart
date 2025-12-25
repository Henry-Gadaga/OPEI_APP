import 'package:json_annotation/json_annotation.dart';

part 'kyc_session_response.g.dart';

@JsonSerializable()
class KycSessionResponse {
  final String sessionUrl;
  final String status;
  final String workflowId;

  KycSessionResponse({
    required this.sessionUrl,
    required this.status,
    required this.workflowId,
  });

  factory KycSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$KycSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KycSessionResponseToJson(this);
}
