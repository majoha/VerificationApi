class VerificationResult {
  final String code;
  final DateTime expiresAt;

  VerificationResult({required this.code, required this.expiresAt});

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      code: json["code"],
      expiresAt: DateTime.parse(json["expiresAt"]).toLocal(),
    );
  }
}
