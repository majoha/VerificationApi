import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';

import '../models/verification_result.dart';
import '../services/verification_service.dart';
import '../widgets/countdown_timer.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final verificationService = VerificationService();

  bool isVerified = false;
  String? verificationCode;
  DateTime? expiresAt;
  Duration timeRemaining = Duration.zero;
  Timer? countdownTimer;
  String status = "Not Verified";

  void startCountdown() {
    countdownTimer?.cancel();
    updateCountdown();
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateCountdown(),
    );
  }

  void updateCountdown() {
    if (expiresAt == null) return;
    final remaining = expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) {
      countdownTimer?.cancel();
      if (!mounted) return;
      setState(() {
        verificationCode = null;
        expiresAt = null;
        timeRemaining = Duration.zero;
        isVerified = false;
        status = "Verification Expired";
      });
      return;
    }
    if (!mounted) return;
    setState(() => timeRemaining = remaining);
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> verifyUser() async {
    setState(() {
      status = "Verifying...";
    });

    final VerificationResult result = await verificationService
        .createVerification();

    setState(() {
      isVerified = true;
      verificationCode = result.code;
      expiresAt = result.expiresAt;
      status = "Verified";
    });

    startCountdown();
  }

  Future<void> verifyCode() async {
    final controller = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Verify Code"),

        content: SizedBox(
          width: 380,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Enter 6-digit verification code",
            ),
          ),
        ),

        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        actions: [
          TextButton.icon(
            onPressed: () async {
              final data = await Clipboard.getData('text/plain');

              if (data?.text != null) {
                controller.text = data!.text!;
              }
            },
            icon: const Icon(Icons.paste_outlined),
            label: const Text("Paste"),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text("Check!"),
          ),
        ],
      ),
    );

    if (code == null) return;

    final bool valid = await verificationService.verifyCode(code);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(valid ? "Verified" : "Verification Failed"),
        content: Row(
          children: [
            Icon(
              valid ? Icons.verified : Icons.cancel,
              color: valid ? Colors.green : Colors.red,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                valid
                    ? "This person has completed a live verification."
                    : "This code is invalid or has expired.",
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> copyCode() async {
    if (verificationCode == null) return;

    await Clipboard.setData(ClipboardData(text: verificationCode!));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Verification code copied.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Verification"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade500, width: 2),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 60),
                        SizedBox(height: 12),
                        Text("Front Camera Preview"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    onPressed: verifyUser,
                    icon: const Icon(Icons.verified_user),
                    label: const Text("Verify"),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: verifyCode,
                    icon: const Icon(Icons.password),
                    label: const Text("Verify Code"),
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isVerified
                                  ? Icons.verified
                                  : Icons.hourglass_empty,
                              color: isVerified
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            Text(status, style: AppTextStyles.heading),
                          ],
                        ),

                        if (verificationCode != null) ...[
                          const SizedBox(height: 20),

                          const Text(
                            "Your Verification Code",
                            style: AppTextStyles.heading,
                          ),

                          const SizedBox(height: 8),

                          SelectableText(
                            verificationCode!,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),

                          const SizedBox(height: 5),

                          if (expiresAt != null)
                            CountdownTimer(
                              expiresAt: expiresAt!,
                              onExpired: () {
                                if (!mounted) return;
                                setState(() {
                                  verificationCode = null;
                                  expiresAt = null;
                                  isVerified = false;
                                  status = "Verification Expired";
                                });
                              },
                            ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: copyCode,
                            icon: const Icon(Icons.copy),
                            label: const Text("Copy Code"),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
