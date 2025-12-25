import 'package:json_annotation/json_annotation.dart';

part 'kyc_session_response.g.dart';

@JsonSerializable()
class KycSessionResponse {
  final String sessionUrl;
  final String status;
  final String workflowId;
  final String? sessionId;
  final String? declineReason;
  final DateTime? lastUpdatedAt;

  KycSessionResponse({
    required this.sessionUrl,
    required this.status,
    required this.workflowId,
    this.sessionId,
    this.declineReason,
    this.lastUpdatedAt,
  });

  factory KycSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$KycSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KycSessionResponseToJson(this);
}
