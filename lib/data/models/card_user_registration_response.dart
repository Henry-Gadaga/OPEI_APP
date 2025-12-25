class CardUserRegistrationResponse {
  final String? id;
  final String? userId;
  final String? cardUserId;
  final String? providerCardUserId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? kycStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool alreadyRegistered;

  const CardUserRegistrationResponse({
    this.id,
    this.userId,
    this.cardUserId,
    this.providerCardUserId,
    this.email,
    this.firstName,
    this.lastName,
    this.kycStatus,
    this.createdAt,
    this.updatedAt,
    this.alreadyRegistered = false,
  });

  factory CardUserRegistrationResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    final alreadyRegistered = json['alreadyRegistered'] as bool? ?? false;

    final id = (json['id'] ?? json['cardUserId'])?.toString();

    return CardUserRegistrationResponse(
      id: id,
      userId: json['userId']?.toString(),
      cardUserId: json['cardUserId']?.toString() ?? id,
      providerCardUserId: json['providerCardUserId']?.toString(),
      email: json['email']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      kycStatus: json['kycStatus']?.toString(),
      createdAt: parseDate(json['createdAt']?.toString()),
      updatedAt: parseDate(json['updatedAt']?.toString()),
      alreadyRegistered: alreadyRegistered,
    );
  }

  CardUserRegistrationResponse copyWith({
    String? id,
    String? userId,
    String? cardUserId,
    String? providerCardUserId,
    String? email,
    String? firstName,
    String? lastName,
    String? kycStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? alreadyRegistered,
  }) {
    return CardUserRegistrationResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardUserId: cardUserId ?? this.cardUserId,
      providerCardUserId: providerCardUserId ?? this.providerCardUserId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      kycStatus: kycStatus ?? this.kycStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      alreadyRegistered: alreadyRegistered ?? this.alreadyRegistered,
    );
  }
}