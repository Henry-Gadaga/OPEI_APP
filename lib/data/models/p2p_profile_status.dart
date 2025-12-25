class P2PProfileStatus {
  final bool hasProfile;

  const P2PProfileStatus({required this.hasProfile});

  factory P2PProfileStatus.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      return P2PProfileStatus(hasProfile: data['hasProfile'] == true);
    }
    return P2PProfileStatus(hasProfile: json['hasProfile'] == true);
  }
}
