/// A money-transfer beneficiary returned by the remittance service.
///
/// Currently only the fields the UI actually shows are typed. Anything else
/// in the response is preserved on the raw map but ignored here.
class Beneficiary {
  final String id;
  final String type;
  final String? providerBeneficiaryId;
  final String? accountName;
  final String? accountNumberMasked;
  final String country;
  final String? currency;
  final String? reference;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Beneficiary({
    required this.id,
    required this.type,
    required this.country,
    required this.status,
    this.providerBeneficiaryId,
    this.accountName,
    this.accountNumberMasked,
    this.currency,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    String? readString(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          final v = json[k];
          if (v is String && v.isNotEmpty) return v;
          return v.toString();
        }
      }
      return null;
    }

    DateTime? readDate(List<String> keys) {
      for (final k in keys) {
        if (!json.containsKey(k) || json[k] == null) continue;
        final v = json[k];
        if (v is DateTime) return v;
        if (v is String && v.isNotEmpty) {
          final parsed = DateTime.tryParse(v);
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    return Beneficiary(
      id: readString(['id', 'beneficiaryId']) ?? '',
      type: (readString(['type']) ?? '').toUpperCase(),
      providerBeneficiaryId:
          readString(['providerBeneficiaryId', 'provider_beneficiary_id']),
      accountName: readString(['accountName', 'account_name', 'name']),
      accountNumberMasked: readString([
        'accountNumberMasked',
        'account_number_masked',
        'accountNumber',
        'account_number',
      ]),
      country: (readString(['country']) ?? '').toUpperCase(),
      currency: readString(['currency'])?.toUpperCase(),
      reference: readString(['reference']),
      status: (readString(['status']) ?? 'UNKNOWN').toUpperCase(),
      createdAt: readDate(['createdAt', 'created_at']),
      updatedAt: readDate(['updatedAt', 'updated_at']),
    );
  }
}
