import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_helpers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_button.dart';

/// Pide iniciar sesión antes de combinar/descargar, con opción de continuar como invitado.
class MergeAuthGateDialog extends StatelessWidget {
  const MergeAuthGateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const MergeAuthGateDialog(),
    );
  }

  static double _widthFor(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= 520) return 420;
    return (screenWidth - 32).clamp(280, 420);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = _widthFor(context);
    final hPad = width >= 400 ? 32.0 : 20.0;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 36, hPad, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Descarga tu PDF',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Crea una cuenta gratis con tu correo para guardar tu historial, '
                  'o continúa sin registrarte. En ambos casos la combinación es gratuita.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Iniciar sesión',
                  icon: Icons.login_rounded,
                  compact: true,
                  isExpanded: true,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    context.go(
                      RouteHelpers.account(
                        redirect: AppRoutes.merge,
                        mergeAfterAuth: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Crear cuenta',
                  icon: Icons.person_add_alt_1_rounded,
                  compact: true,
                  isExpanded: true,
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    context.go(
                      RouteHelpers.account(
                        redirect: AppRoutes.merge,
                        register: true,
                        mergeAfterAuth: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Continuar sin cuenta',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
