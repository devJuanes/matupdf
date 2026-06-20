import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_button.dart';
import '../controllers/merge_controller.dart';

class PdfMergeToolbar extends StatelessWidget {
  const PdfMergeToolbar({
    super.key,
    required this.onMerge,
  });

  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MergeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = Responsive.isMobile(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720 || isMobile;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ToolbarAction(
                    icon: Icons.rotate_90_degrees_cw_outlined,
                    label: 'Girar todo',
                    onTap: controller.files.isEmpty ? null : controller.rotateAll,
                  ),
                  _ToolbarAction(
                    icon: Icons.sort_by_alpha_rounded,
                    label: 'Ordenar A-Z',
                    onTap: controller.files.isEmpty
                        ? null
                        : controller.sortAlphabetically,
                  ),
                  _TextActionButton(
                    icon: Icons.add_rounded,
                    label: 'Agregar',
                    onTap: controller.isProcessingFiles ? null : controller.pickFiles,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppButton(
                label: controller.isMerging ? 'Combinando…' : 'Combinar PDFs',
                icon: Icons.merge_type_rounded,
                compact: true,
                isExpanded: true,
                isLoading: controller.isMerging,
                onPressed: controller.canMerge ? onMerge : null,
              ),
            ],
          );
        }

        return Row(
          children: [
            _ToolbarAction(
              icon: Icons.rotate_90_degrees_cw_outlined,
              label: 'Girar todo',
              onTap: controller.files.isEmpty ? null : controller.rotateAll,
            ),
            const SizedBox(width: 4),
            _ToolbarAction(
              icon: Icons.sort_by_alpha_rounded,
              label: 'Ordenar A-Z',
              onTap:
                  controller.files.isEmpty ? null : controller.sortAlphabetically,
            ),
            const SizedBox(width: 8),
            _TextActionButton(
              icon: Icons.add_rounded,
              label: 'Agregar archivo',
              onTap: controller.isProcessingFiles ? null : controller.pickFiles,
            ),
            const Spacer(),
            if (controller.files.length >= 2)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${controller.files.length} archivos listos',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ),
            AppButton(
              label: controller.isMerging ? 'Combinando…' : 'Combinar PDFs',
              icon: Icons.merge_type_rounded,
              compact: true,
              isLoading: controller.isMerging,
              onPressed: controller.canMerge ? onMerge : null,
            ),
          ],
        );
      },
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: Theme.of(context).textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ToolbarAction extends StatefulWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_ToolbarAction> createState() => _ToolbarActionState();
}

class _ToolbarActionState extends State<_ToolbarAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton.icon(
        onPressed: widget.onTap,
        icon: Icon(
          widget.icon,
          size: 16,
          color: enabled
              ? (_hovered ? AppColors.primary : AppColors.textSecondaryLight)
              : AppColors.textSecondaryLight.withValues(alpha: 0.4),
        ),
        label: Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: enabled
                    ? (_hovered
                        ? AppColors.primary
                        : AppColors.textSecondaryLight)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.4),
              ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
