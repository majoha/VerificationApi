import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/verification_result.dart';

class VerificationService {
  static const String baseUrl = "https://verificationapi-smti.onrender.com";

  Future<VerificationResult> createVerification() async {
    final response = await http.post(Uri.parse("$baseUrl/createVerification"));

    if (response.statusCode != 200) {
      throw Exception("Failed to create verification.");
    }

    return VerificationResult.fromJson(jsonDecode(response.body));
  }

  Future<bool> verifyCode(String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/checkCode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );

    if (response.statusCode != 200) {
      throw Exception("Verification failed: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> && data["valid"] is bool) {
      return data["valid"] as bool;
    }

    throw Exception("Unexpected /checkCode response: ${response.body}");
  }
}
