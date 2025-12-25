import 'package:json_annotation/json_annotation.dart';

part 'transfer_fee_request.g.dart';

@JsonSerializable()
class TransferPreviewRequest {
  final String toUserId;
  final int amount;

  TransferPreviewRequest({
    required this.toUserId,
    required this.amount,
  });

  factory TransferPreviewRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferPreviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferPreviewRequestToJson(this);
}
