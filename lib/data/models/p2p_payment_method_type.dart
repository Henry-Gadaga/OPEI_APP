class P2PPaymentMethodType {
  final String id;
  final String currency;
  final String methodType; // e.g. BANK, MOBILE_MONEY
  final String providerName; // e.g. FNB Zambia, MTN
  final bool isActive;

  const P2PPaymentMethodType({
    required this.id,
    required this.currency,
    required this.methodType,
    required this.providerName,
    required this.isActive,
  });

  factory P2PPaymentMethodType.fromJson(Map<String, dynamic> json) {
    return P2PPaymentMethodType(
      id: (json['id'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString().toUpperCase(),
      methodType: (json['methodType'] ?? '').toString().toUpperCase(),
      providerName: (json['providerName'] ?? '').toString(),
      isActive: json['isActive'] == true,
    );
  }
}
