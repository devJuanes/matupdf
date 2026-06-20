import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/pdf_file_item.dart';
import 'pdf_thumbnail_image.dart';

class PdfPreviewCard extends StatefulWidget {
  const PdfPreviewCard({
    super.key,
    required this.file,
    required this.onRotate,
    required this.onZoom,
    required this.onDelete,
    required this.onDuplicate,
    this.width = 156,
    this.orderNumber,
  });

  final PdfFileItem file;
  final VoidCallback onRotate;
  final VoidCallback onZoom;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final double width;
  final int? orderNumber;

  @override
  State<PdfPreviewCard> createState() => _PdfPreviewCardState();
}

class _PdfPreviewCardState extends State<PdfPreviewCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = PdfLabelColors.forIndex(widget.file.colorIndex);
    final isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: widget.width,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.width * 1.28,
              decoration: BoxDecoration(
                color: _hovered
                    ? const Color(0xFFE3F2FD).withValues(alpha: isDark ? 0.15 : 1)
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: _hovered
                      ? const Color(0xFF90CAF9)
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                  width: _hovered ? 2 : 1,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.orderNumber != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.orderNumber}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.file.isThumbnailLoading
                          ? const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : PdfThumbnailImage(
                              path: widget.file.thumbnailPath,
                              rotation: widget.file.rotation,
                            ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _hovered || isMobile ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: _HoverToolbar(
                      onRotate: widget.onRotate,
                      onZoom: widget.onZoom,
                      onDelete: widget.onDelete,
                      onDuplicate: widget.onDuplicate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? labelColor.withValues(alpha: 0.25)
                    : labelColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                _truncateName(widget.file.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.file.pageCount == 1
                  ? '1 página'
                  : '${widget.file.pageCount} páginas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              FormatUtils.fileSize(widget.file.size),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateName(String name) {
    if (name.length <= 22) return name;
    return '${name.substring(0, 18)}...${name.substring(name.length - 4)}';
  }
}

class _HoverToolbar extends StatelessWidget {
  const _HoverToolbar({
    required this.onRotate,
    required this.onZoom,
    required this.onDelete,
    required this.onDuplicate,
  });

  final VoidCallback onRotate;
  final VoidCallback onZoom;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolbarButton(
              icon: Icons.zoom_in_rounded,
              tooltip: 'Acercar',
              onTap: onZoom,
            ),
            _ToolbarButton(
              icon: Icons.copy_all_rounded,
              tooltip: 'Duplicar',
              onTap: onDuplicate,
            ),
            _ToolbarButton(
              icon: Icons.rotate_90_degrees_cw_rounded,
              tooltip: 'Rotar',
              onTap: onRotate,
            ),
            _ToolbarButton(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Eliminar',
              onTap: onDelete,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDestructive
        ? (_hovered ? const Color(0xFFFFEBEE) : Colors.transparent)
        : (_hovered ? const Color(0xFFE3F2FD) : Colors.transparent);
    final color = widget.isDestructive
        ? const Color(0xFFE53935)
        : const Color(0xFF1976D2);

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
