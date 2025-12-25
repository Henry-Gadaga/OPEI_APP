class P2PUserPaymentMethod {
  final String id;
  final String paymentMethodTypeId;
  final String currency;
  final String methodType;
  final String providerName;
  final String accountName;
  final String accountNumberMasked;
  final String? extraDetails;
  final bool isVerified;
  final DateTime? createdAt;

  const P2PUserPaymentMethod({
    required this.id,
    required this.paymentMethodTypeId,
    required this.currency,
    required this.methodType,
    required this.providerName,
    required this.accountName,
    required this.accountNumberMasked,
    this.extraDetails,
    required this.isVerified,
    this.createdAt,
  });

  factory P2PUserPaymentMethod.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return P2PUserPaymentMethod(
      id: (json['id'] ?? '').toString(),
      paymentMethodTypeId: (json['paymentMethodTypeId'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString().toUpperCase(),
      methodType: (json['methodType'] ?? '').toString().toUpperCase(),
      providerName: (json['providerName'] ?? '').toString(),
      accountName: (json['accountName'] ?? '').toString(),
      accountNumberMasked: (json['accountNumberMasked'] ?? '').toString(),
      extraDetails: (json['extraDetails'] ?? '').toString().trim().isEmpty
          ? null
          : (json['extraDetails'] ?? '').toString(),
      isVerified: json['isVerified'] == true,
      createdAt: parseDate(json['createdAt']),
    );
  }
}
