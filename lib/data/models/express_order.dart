/// Lifecycle status for an Express P2P order.
///
/// Mirrors the backend status machine:
/// `PENDING_AGENT → AWAITING_PAYMENT → PAID_BY_USER → COMPLETED`
/// with terminal `EXPIRED` / `CANCELLED`.
enum ExpressOrderStatus {
  pendingAgent,
  awaitingPayment,
  paidByUser,
  disputed,
  completed,
  expired,
  cancelled,
  unknown;

  static ExpressOrderStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PENDING_AGENT':
        return ExpressOrderStatus.pendingAgent;
      case 'AWAITING_PAYMENT':
        return ExpressOrderStatus.awaitingPayment;
      case 'PAID_BY_USER':
        return ExpressOrderStatus.paidByUser;
      case 'DISPUTED':
        return ExpressOrderStatus.disputed;
      case 'COMPLETED':
        return ExpressOrderStatus.completed;
      case 'EXPIRED':
        return ExpressOrderStatus.expired;
      case 'CANCELLED':
        return ExpressOrderStatus.cancelled;
      default:
        return ExpressOrderStatus.unknown;
    }
  }

  /// Active = still in flight, should appear under "Active" on the hub and be
  /// eligible for polling.
  bool get isActive =>
      this == ExpressOrderStatus.pendingAgent ||
      this == ExpressOrderStatus.awaitingPayment ||
      this == ExpressOrderStatus.paidByUser ||
      this == ExpressOrderStatus.disputed;

  /// Terminal = no further transitions; stop polling.
  bool get isTerminal =>
      this == ExpressOrderStatus.completed ||
      this == ExpressOrderStatus.expired ||
      this == ExpressOrderStatus.cancelled;

  /// Whether a customer-facing screen should poll for updates in this state.
  bool get shouldPoll =>
      this == ExpressOrderStatus.pendingAgent ||
      this == ExpressOrderStatus.paidByUser;

  /// Whether contact details are relevant for customer/agent communication.
  bool get shouldShowContact =>
      this == ExpressOrderStatus.awaitingPayment ||
      this == ExpressOrderStatus.paidByUser ||
      this == ExpressOrderStatus.completed;
}

/// Lightweight reference to a platform payment method type as embedded in an
/// order / preview response.
class ExpressMethodType {
  final String id;
  final String providerName;
  final String methodType;
  final String currency;

  const ExpressMethodType({
    required this.id,
    required this.providerName,
    required this.methodType,
    required this.currency,
  });

  factory ExpressMethodType.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return ExpressMethodType(
      id: (map['id'] ?? '').toString(),
      providerName: (map['providerName'] ?? '').toString(),
      methodType: (map['methodType'] ?? '').toString().toUpperCase(),
      currency: (map['currency'] ?? '').toString().toUpperCase(),
    );
  }
}

/// The agent's payment account, revealed to the customer only after an agent
/// accepts (status `AWAITING_PAYMENT`).
class ExpressAgentPaymentMethod {
  final String accountName;
  final String accountNumber;
  final String providerName;
  final String? extraDetails;

  const ExpressAgentPaymentMethod({
    required this.accountName,
    required this.accountNumber,
    required this.providerName,
    this.extraDetails,
  });

  factory ExpressAgentPaymentMethod.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final extra = (map['extraDetails'] as Object?)?.toString();
    return ExpressAgentPaymentMethod(
      accountName: (map['accountName'] ?? '').toString(),
      accountNumber: (map['accountNumber'] ?? '').toString(),
      providerName: (map['providerName'] ?? '').toString(),
      extraDetails: (extra != null && extra.trim().isNotEmpty) ? extra : null,
    );
  }
}

/// Agent identity block embedded in express order responses.
class ExpressOrderAgent {
  final String id;
  final String userId;
  final bool isActive;
  final String? phoneNumber;

  const ExpressOrderAgent({
    required this.id,
    required this.userId,
    required this.isActive,
    this.phoneNumber,
  });

  factory ExpressOrderAgent.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return ExpressOrderAgent(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      isActive: map['isActive'] == true,
      phoneNumber: ExpressOrder._parseOptionalText(map['phoneNumber']),
    );
  }
}

class ExpressOrderDispute {
  final String id;
  final String? openedById;
  final String? message;
  final List<String> evidenceUrls;
  final String? status;
  final String? adminNotes;
  final DateTime? resolvedAt;

  const ExpressOrderDispute({
    required this.id,
    this.openedById,
    this.message,
    this.evidenceUrls = const <String>[],
    this.status,
    this.adminNotes,
    this.resolvedAt,
  });

  bool get isResolved {
    final normalized = (status ?? '').trim().toUpperCase();
    return normalized == 'RESOLVED' || normalized == 'CLOSED';
  }

  factory ExpressOrderDispute.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return ExpressOrderDispute(
      id: (map['id'] ?? '').toString(),
      openedById: ExpressOrder._parseOptionalText(map['openedById']),
      message: ExpressOrder._parseOptionalText(map['message']),
      evidenceUrls: ExpressOrder._parseProofUrls(
        map['evidenceUrls'] ?? map['imageUrls'],
      ),
      status: ExpressOrder._parseOptionalText(map['status']),
      adminNotes: ExpressOrder._parseOptionalText(map['adminNotes']),
      resolvedAt: ExpressOrder._parseDate(map['resolvedAt']),
    );
  }
}

/// A single Express P2P order (customer or agent view).
///
/// All monetary fields are integer cents. `amountUsdCents` is USD; the fiat
/// amount the customer pays is `fiatAmountCents` in `quoteCurrency`.
class ExpressOrder {
  final String id;
  final String? userId;
  final ExpressOrderStatus status;
  final int amountUsdCents;
  final int lockedRateCents;
  final int fiatAmountCents;
  final String quoteCurrency;
  final ExpressMethodType? paymentMethodType;
  final ExpressOrderAgent? agent;
  final ExpressAgentPaymentMethod? agentPaymentMethod;
  final String? agentContactNumber;
  final String? buyerContactNumber;
  final DateTime? cancelledAt;
  final DateTime? disputedAt;
  final ExpressOrderDispute? dispute;
  final List<String> proofUrls;
  final DateTime? expiresAt;
  final DateTime? paidAt;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const ExpressOrder({
    required this.id,
    required this.status,
    required this.amountUsdCents,
    required this.lockedRateCents,
    required this.fiatAmountCents,
    required this.quoteCurrency,
    this.userId,
    this.paymentMethodType,
    this.agent,
    this.agentPaymentMethod,
    this.agentContactNumber,
    this.buyerContactNumber,
    this.cancelledAt,
    this.disputedAt,
    this.dispute,
    this.proofUrls = const <String>[],
    this.expiresAt,
    this.paidAt,
    this.completedAt,
    this.createdAt,
  });

  factory ExpressOrder.fromJson(Map<String, dynamic> json) {
    return ExpressOrder(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] as Object?)?.toString(),
      status: ExpressOrderStatus.fromApi(json['status'] as String?),
      amountUsdCents: _toCents(json['amountUsdCents']),
      lockedRateCents: _toCents(json['lockedRateCents']),
      fiatAmountCents: _toCents(json['fiatAmountCents']),
      quoteCurrency: (json['quoteCurrency'] ?? '').toString().toUpperCase(),
      paymentMethodType: json['paymentMethodType'] is Map<String, dynamic>
          ? ExpressMethodType.fromJson(
              json['paymentMethodType'] as Map<String, dynamic>,
            )
          : null,
      agent: json['agent'] is Map<String, dynamic>
          ? ExpressOrderAgent.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      agentPaymentMethod: json['agentPaymentMethod'] is Map<String, dynamic>
          ? ExpressAgentPaymentMethod.fromJson(
              json['agentPaymentMethod'] as Map<String, dynamic>,
            )
          : null,
      agentContactNumber: _parseOptionalText(json['agentContactNumber']),
      buyerContactNumber: _parseOptionalText(json['buyerContactNumber']),
      cancelledAt: _parseDate(json['cancelledAt']),
      disputedAt: _parseDate(json['disputedAt']),
      dispute: json['dispute'] is Map<String, dynamic>
          ? ExpressOrderDispute.fromJson(
              json['dispute'] as Map<String, dynamic>,
            )
          : null,
      proofUrls: _parseProofUrls(json['proofs']),
      expiresAt: _parseDate(json['expiresAt']),
      paidAt: _parseDate(json['paidAt']),
      completedAt: _parseDate(json['completedAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static int _toCents(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.round();
    final parsed = int.tryParse(value.toString().trim());
    if (parsed != null) return parsed;
    final asDouble = double.tryParse(value.toString().trim());
    return asDouble?.round() ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _parseOptionalText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static List<String> _parseProofUrls(dynamic value) {
    if (value is! List) return const <String>[];
    final urls = <String>[];
    for (final item in value) {
      if (item is String && item.trim().isNotEmpty) {
        urls.add(item.trim());
      } else if (item is Map) {
        final url =
            (item['url'] ??
                    item['publicUrl'] ??
                    item['fileUrl'] ??
                    item['proofUrl'])
                ?.toString();
        if (url != null && url.trim().isNotEmpty) {
          urls.add(url.trim());
        }
      }
    }
    return List<String>.unmodifiable(urls);
  }
}
