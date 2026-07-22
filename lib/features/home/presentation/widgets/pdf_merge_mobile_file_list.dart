import 'package:flutter/material.dart';

import '../../../../core/utils/format_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/pdf_file_item.dart';
import 'pdf_thumbnail_image.dart';

/// Lista compacta y reordenable para móvil (muchos PDFs sin ocupar toda la pantalla).
class PdfMergeMobileFileList extends StatelessWidget {
  const PdfMergeMobileFileList({
    super.key,
    required this.files,
    required this.onInsertAt,
    required this.onRotate,
    required this.onZoom,
    required this.onDelete,
    required this.onDuplicate,
    required this.onReorder,
  });

  final List<PdfFileItem> files;
  final Future<void> Function({int? insertAt}) onInsertAt;
  final void Function(String id) onRotate;
  final void Function(PdfFileItem file) onZoom;
  final void Function(String id) onDelete;
  final void Function(String id) onDuplicate;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(
                Icons.swap_vert_rounded,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Mantén pulsado y arrastra para reordenar',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ),
            ],
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: files.length,
          onReorder: onReorder,
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              color: isDark ? AppColors.cardDark : Colors.white,
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final file = files[index];
            return _MobileFileTile(
              key: ValueKey(file.id),
              file: file,
              index: index,
              onRotate: () => onRotate(file.id),
              onZoom: () => onZoom(file),
              onDelete: () => onDelete(file.id),
              onDuplicate: () => onDuplicate(file.id),
            );
          },
        ),
        const SizedBox(height: 10),
        _AddMoreRow(onTap: () => onInsertAt(insertAt: files.length)),
      ],
    );
  }
}

class _MobileFileTile extends StatelessWidget {
  const _MobileFileTile({
    super.key,
    required this.file,
    required this.index,
    required this.onRotate,
    required this.onZoom,
    required this.onDelete,
    required this.onDuplicate,
  });

  final PdfFileItem file;
  final int index;
  final VoidCallback onRotate;
  final VoidCallback onZoom;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 22,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 44,
              height: 58,
              child: file.isThumbnailLoading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : PdfThumbnailImage(
                      path: file.thumbnailPath,
                      rotation: file.rotation,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${file.pageCount} pág. · ${FormatUtils.fileSize(file.size)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              switch (value) {
                case 'zoom':
                  onZoom();
                case 'rotate':
                  onRotate();
                case 'duplicate':
                  onDuplicate();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'zoom', child: Text('Vista previa')),
              const PopupMenuItem(value: 'rotate', child: Text('Rotar')),
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _AddMoreRow extends StatelessWidget {
  const _AddMoreRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Agregar más PDFs',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
