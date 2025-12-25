import 'package:json_annotation/json_annotation.dart';

part 'wallet_lookup_request.g.dart';

@JsonSerializable()
class WalletLookupRequest {
  final String email;

  WalletLookupRequest({required this.email});

  factory WalletLookupRequest.fromJson(Map<String, dynamic> json) =>
      _$WalletLookupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WalletLookupRequestToJson(this);
}
