import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../theme/app_colors.dart';

class MergeProgressDialog extends StatelessWidget {
  const MergeProgressDialog({
    super.key,
    required this.progress,
    required this.isComplete,
  });

  final double progress;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).round();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 420,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isComplete ? Icons.check_circle_outline : Icons.download_rounded,
                size: 36,
                color: isComplete ? AppColors.success : const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 28),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: isComplete
                        ? '¡Tu archivo está listo!'
                        : 'Tu archivo se está procesando ',
                  ),
                  if (!isComplete)
                    TextSpan(
                      text: '$percent%',
                      style: const TextStyle(color: Color(0xFF2196F3)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: isComplete ? 1 : progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                color: isComplete ? AppColors.success : const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
