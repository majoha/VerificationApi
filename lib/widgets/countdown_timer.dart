import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback onExpired;

  const CountdownTimer({
    super.key,
    required this.expiresAt,
    required this.onExpired,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;

  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();

    _update();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final remaining = widget.expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      _timer?.cancel();

      widget.onExpired();

      return;
    }

    if (!mounted) return;

    setState(() {
      _remaining = remaining;
    });
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');

    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              color: AppColors.warning,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              "Expires in ${_format(_remaining)}",
              style: AppTextStyles.timer,
            ),
          ],
        ),
      ),
    );
  }
}
