import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/pdf_annotation.dart';
import '../controllers/edit_controller.dart';

class PdfEditToolbar extends StatelessWidget {
  const PdfEditToolbar({super.key, required this.controller});

  final EditController controller;

  static const _tools = <EditTool>[
    EditTool.thumbnails,
    EditTool.move,
    EditTool.undo,
    EditTool.redo,
    EditTool.editText,
    EditTool.addText,
    EditTool.sign,
    EditTool.eraser,
    EditTool.highlight,
    EditTool.pencil,
    EditTool.image,
    EditTool.ellipse,
    EditTool.annotations,
    EditTool.links,
    EditTool.cross,
    EditTool.check,
    EditTool.more,
    EditTool.search,
    EditTool.pageLayout,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: _tools.length,
        separatorBuilder: (_, _) => const SizedBox(width: 2),
        itemBuilder: (context, index) {
          final tool = _tools[index];
          final selected = controller.tool == tool ||
              (tool == EditTool.thumbnails && controller.showThumbnails);
          final enabled = tool.isImplemented ||
              tool == EditTool.thumbnails ||
              tool == EditTool.undo ||
              tool == EditTool.redo;

          final disabledUndo = tool == EditTool.undo && !controller.canUndo;
          final disabledRedo = tool == EditTool.redo && !controller.canRedo;
          final isDisabled = !enabled || disabledUndo || disabledRedo;

          return Tooltip(
            message: enabled ? tool.label : '${tool.label} (próximamente)',
            child: InkWell(
              onTap: isDisabled ? null : () => controller.setTool(tool),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 68,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tool.icon,
                      size: 22,
                      color: isDisabled
                          ? (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)
                          : selected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
