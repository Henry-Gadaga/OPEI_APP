class P2PUserProfile {
  final String id;
  final String userId;
  final String displayName;
  final String nickname;
  final String bio;
  final String preferredLanguage;
  final String preferredCurrency;
  final double rating;
  final int totalTrades;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  const P2PUserProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.nickname,
    required this.bio,
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.rating,
    required this.totalTrades,
    required this.createdAt,
    required this.updatedAt,
    this.raw = const <String, dynamic>{},
  });

  factory P2PUserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value);
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String && value.isNotEmpty) {
        return int.tryParse(value);
      }
      return null;
    }

    final normalized = Map<String, dynamic>.from(json);
    return P2PUserProfile(
      id: (normalized['id'] ?? '').toString(),
      userId: (normalized['userId'] ?? '').toString(),
      displayName: (normalized['displayName'] ?? '').toString(),
      nickname: (normalized['nickname'] ?? '').toString(),
      bio: (normalized['bio'] ?? '').toString(),
      preferredLanguage: (normalized['preferredLanguage'] ?? 'en').toString(),
      preferredCurrency: (normalized['preferredCurrency'] ?? 'USD').toString().toUpperCase(),
      rating: parseDouble(normalized['rating']) ?? 0,
      totalTrades: parseInt(normalized['totalTrades']) ?? 0,
      createdAt: parseDate(normalized['createdAt']),
      updatedAt: parseDate(normalized['updatedAt']),
      raw: normalized,
    );
  }

  String get initials {
    final nameParts = <String>[];
    if (displayName.trim().isNotEmpty) {
      nameParts.addAll(displayName.trim().split(' '));
    } else if (nickname.trim().isNotEmpty) {
      nameParts.add(nickname.trim());
    }
    final firstTwo = nameParts.where((part) => part.isNotEmpty).map((part) => part[0]).take(2).toList();
    if (firstTwo.isEmpty) {
      return '?';
    }
    return firstTwo.map((ch) => ch.toUpperCase()).join();
  }

  String get primaryName {
    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    return 'Trader';
  }

  String get usernameLabel {
    if (nickname.trim().isEmpty) {
      return '—';
    }
    return nickname.startsWith('@') ? nickname : '@$nickname';
  }

  String? get friendlyBio => bio.trim().isEmpty ? null : bio.trim();

  String get friendlyLanguage {
    const lookup = {
      'en': 'English',
      'fr': 'French',
      'pt': 'Portuguese',
      'es': 'Spanish',
      'sw': 'Swahili',
    };
    final normalized = preferredLanguage.trim().toLowerCase();
    return lookup[normalized] ?? normalized.toUpperCase();
  }
}