class AuthTokenEntity {
  final String accessToken;
  final String type;
  final DateTime? expiry;

  const AuthTokenEntity({
    required this.accessToken,
    this.type = 'Bearer',
    this.expiry,
  });

  bool get isExpired {
    if (expiry == null) return false;
    // Buffer by 60 seconds
    return DateTime.now().isAfter(expiry!.subtract(const Duration(seconds: 60)));
  }
}
