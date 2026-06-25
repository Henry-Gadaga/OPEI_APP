import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/utils/referral_code_parser.dart';

class ReferralApplyResult {
  final bool hasReferral;
  final String? referrerUserId;
  final String? rewardStatus;

  const ReferralApplyResult({
    required this.hasReferral,
    required this.referrerUserId,
    required this.rewardStatus,
  });

  factory ReferralApplyResult.fromJson(Map<String, dynamic> json) {
    return ReferralApplyResult(
      hasReferral: json['hasReferral'] == true,
      referrerUserId: json['referrerUserId'] as String?,
      rewardStatus: json['rewardStatus'] as String?,
    );
  }
}

class MyReferralSummary {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final int successfulReferrals;
  final int totalEarnedCents;

  const MyReferralSummary({
    required this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.totalEarnedCents,
  });

  factory MyReferralSummary.fromJson(Map<String, dynamic> json) {
    return MyReferralSummary(
      referralCode: (json['referralCode'] as String? ?? '').trim(),
      referralLink: (json['referralLink'] as String? ?? '').trim(),
      totalReferrals: (json['totalReferrals'] as num?)?.toInt() ?? 0,
      successfulReferrals: (json['successfulReferrals'] as num?)?.toInt() ?? 0,
      totalEarnedCents: (json['totalEarnedCents'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReferralRepository {
  final ApiClient _apiClient;

  ReferralRepository(this._apiClient);

  Future<ReferralApplyResult> applyReferralCode(String rawInput) async {
    final referralCode = ReferralCodeParser.normalize(rawInput);
    if (referralCode.isEmpty) {
      throw ApiError(message: 'Enter a valid referral code', statusCode: 400);
    }

    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/user/me/referral/apply',
      data: {'referralCode': referralCode},
    );

    final success = payload['success'] == true;
    final data = payload['data'];
    if (!success || data is! Map<String, dynamic>) {
      throw ApiError(
        message: (payload['message'] as String?) ?? 'Failed to apply referral',
      );
    }

    return ReferralApplyResult.fromJson(data);
  }

  Future<MyReferralSummary> getMyReferral() async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/user/me/referral',
    );
    final success = payload['success'] == true;
    final data = payload['data'];
    if (!success || data is! Map<String, dynamic>) {
      throw ApiError(
        message:
            (payload['message'] as String?) ??
            'Failed to load referral details',
      );
    }
    return MyReferralSummary.fromJson(data);
  }
}
