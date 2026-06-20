import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../theme/app_colors.dart';

class FileUploadOverlay extends StatelessWidget {
  const FileUploadOverlay({
    super.key,
    required this.progress,
    required this.fileName,
    required this.done,
    required this.total,
  });

  final double progress;
  final String? fileName;
  final int done;
  final int total;

  static Future<T?> showWhileProcessing<T>(
    BuildContext context, {
    required bool Function() isActive,
    required double Function() progress,
    required String? Function() fileName,
    required int Function() done,
    required int Function() total,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return _UploadDialogHost(
          isActive: isActive,
          progress: progress,
          fileName: fileName,
          done: done,
          total: total,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = (progress * 100).clamp(0, 100).round();

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value: total > 1 ? progress : null,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Cargando archivos',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  total > 1
                      ? 'Procesando $done de $total · $percent%'
                      : 'Generando vista previa…',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
                if (fileName != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 18,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            fileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: total > 1 ? progress : null,
                    minHeight: 5,
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : const Color(0xFFE2E8F0),
                    color: AppColors.primary,
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

class _UploadDialogHost extends StatefulWidget {
  const _UploadDialogHost({
    required this.isActive,
    required this.progress,
    required this.fileName,
    required this.done,
    required this.total,
  });

  final bool Function() isActive;
  final double Function() progress;
  final String? Function() fileName;
  final int Function() done;
  final int Function() total;

  @override
  State<_UploadDialogHost> createState() => _UploadDialogHostState();
}

class _UploadDialogHostState extends State<_UploadDialogHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDone());
  }

  void _checkDone() {
    if (!mounted) return;
    if (!widget.isActive()) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDone());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: FileUploadOverlay(
        progress: widget.progress(),
        fileName: widget.fileName(),
        done: widget.done(),
        total: widget.total(),
      ),
    );
  }
}
