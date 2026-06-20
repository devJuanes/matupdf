import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Logo oficial desde `web/icons/logo.png` (incluye texto MatuPDF).
class MatuLogo extends StatelessWidget {
  const MatuLogo({
    super.key,
    this.height = 40,
    this.showText = false,
  });

  final double height;
  final bool showText;

  static const _logoPath = 'icons/logo.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          _logoPath,
          height: height,
          fit: BoxFit.contain,
          semanticLabel: AppConstants.appName,
          errorBuilder: (_, __, ___) => _FallbackLogo(height: height),
        ),
        if (showText) ...[
          SizedBox(width: height * 0.25),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
          ),
        ],
      ],
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(height * 0.28),
      ),
      child: Icon(
        Icons.picture_as_pdf_rounded,
        color: Colors.white,
        size: height * 0.55,
      ),
    );
  }
}
