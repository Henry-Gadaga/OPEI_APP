import 'package:json_annotation/json_annotation.dart';

part 'transfer_request.g.dart';

@JsonSerializable()
class TransferRequest {
  final String toUserId;
  final int amount;
  final String? description;

  TransferRequest({
    required this.toUserId,
    required this.amount,
    this.description,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRequestToJson(this);
}
