import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_button.dart';
import '../../data/models/pdf_file_item.dart';
import '../controllers/merge_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/widgets/merge_auth_gate_dialog.dart';
import '../../../contact/data/contact_repository.dart';
import 'file_upload_overlay.dart';
import 'merge_progress_dialog.dart';
import 'pdf_merge_toolbar.dart';
import 'pdf_preview_card.dart';
import 'pdf_zoom_dialog.dart';

class PdfMergeWorkspace extends StatefulWidget {
  const PdfMergeWorkspace({super.key});

  @override
  State<PdfMergeWorkspace> createState() => _PdfMergeWorkspaceState();
}

class _PdfMergeWorkspaceState extends State<PdfMergeWorkspace> {
  bool _isDragging = false;
  bool _mergeDialogShown = false;
  bool _uploadDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryPendingMergeAfterAuth());
  }

  void _tryPendingMergeAfterAuth() {
    if (!mounted) return;
    final controller = context.read<MergeController>();
    if (controller.consumeMergeAfterAuthRequest() && controller.canMerge) {
      _startMerge(context, skipAuthGate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MergeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _handleMergeDialog(controller);
    _handleUploadDialog(controller);

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        controller.addDroppedFiles(details.files);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: _isDragging
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: _isDragging ? 2 : 1,
          ),
          boxShadow: AppColors.cardShadow(isDark: isDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: controller.hasFiles
            ? _FilesWorkspace(
                isDragging: _isDragging,
                onMerge: () => _startMerge(context),
              )
            : _EmptyUploadArea(
                isDragging: _isDragging,
                onPickFiles: () => controller.pickFiles(),
              ),
      ),
    );
  }

  void _handleUploadDialog(MergeController controller) {
    if (controller.isProcessingFiles && !_uploadDialogShown) {
      _uploadDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await FileUploadOverlay.showWhileProcessing(
          context,
          isActive: () =>
              context.read<MergeController>().isProcessingFiles,
          progress: () =>
              context.read<MergeController>().processingProgress,
          fileName: () =>
              context.read<MergeController>().processingLabel,
          done: () => context.read<MergeController>().processingDone,
          total: () => context.read<MergeController>().processingTotal,
        );
        if (mounted) _uploadDialogShown = false;
      });
    }
  }

  void _handleMergeDialog(MergeController controller) {
    if (controller.isMerging && !_mergeDialogShown) {
      _mergeDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PopScope(
            canPop: false,
            child: MergeProgressDialog(
              progress: controller.mergeProgress,
              isComplete: false,
            ),
          ),
        );
      });
    }

    if (!controller.isMerging && _mergeDialogShown) {
      if (controller.mergeProgress >= 1 || controller.errorMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) navigator.pop();
          if (controller.mergeProgress >= 1 &&
              controller.errorMessage == null) {
            showDialog<void>(
              context: context,
              builder: (_) => const MergeProgressDialog(
                progress: 1,
                isComplete: true,
              ),
            ).then((_) => controller.dismissMergeResult());
          }
          _mergeDialogShown = false;
        });
      }
    }
  }

  Future<void> _startMerge(BuildContext context, {bool skipAuthGate = false}) async {
    final auth = context.read<AuthController>();
    if (!skipAuthGate && !auth.isAuthenticated) {
      final continueAsGuest = await MergeAuthGateDialog.show(context);
      if (continueAsGuest != true || !mounted) return;
    }

    final mergeController = context.read<MergeController>();
    await mergeController.mergePdfs();

    if (!mounted) return;
    if (mergeController.mergedOutputPath != null &&
        mergeController.errorMessage == null) {
      await DownloadLogger().logMerge(
        auth: auth,
        fileCount: mergeController.files.length,
        fileNames: mergeController.files.map((f) => f.name).toList(),
      );
    }
  }
}

class _FilesWorkspace extends StatelessWidget {
  const _FilesWorkspace({
    required this.isDragging,
    required this.onMerge,
  });

  final bool isDragging;
  final VoidCallback onMerge;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MergeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
          child: PdfMergeToolbar(onMerge: onMerge),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              Responsive.value(context: context, mobile: 14, desktop: 20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDragging)
                  _DropHintBanner(isDark: isDark),
                _FilesGrid(
                  files: controller.files,
                  onInsertAt: controller.pickFiles,
                  onRotate: controller.rotateFile,
                  onZoom: (file) => PdfZoomDialog.show(context, file),
                  onDelete: controller.removeFile,
                  onDuplicate: controller.duplicateFile,
                  onReorder: controller.reorderFiles,
                  onReorderToEnd: (from) =>
                      controller.reorderFiles(from, controller.files.length),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _MessageBanner(
                    message: controller.errorMessage!,
                    color: AppColors.primary,
                    icon: Icons.error_outline,
                  ),
                ],
                if (controller.mergedOutputPath != null &&
                    !controller.isMerging) ...[
                  const SizedBox(height: 16),
                  _MessageBanner(
                    message:
                        '¡PDF combinado! La descarga debería iniciarse automáticamente.',
                    color: AppColors.success,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropHintBanner extends StatelessWidget {
  const _DropHintBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.file_download_outlined, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            'Suelta para agregar más archivos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _FilesGrid extends StatelessWidget {
  const _FilesGrid({
    required this.files,
    required this.onInsertAt,
    required this.onRotate,
    required this.onZoom,
    required this.onDelete,
    required this.onDuplicate,
    required this.onReorder,
    required this.onReorderToEnd,
  });

  final List<PdfFileItem> files;
  final Future<void> Function({int? insertAt}) onInsertAt;
  final void Function(String id) onRotate;
  final void Function(PdfFileItem file) onZoom;
  final void Function(String id) onDelete;
  final void Function(String id) onDuplicate;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int fromIndex) onReorderToEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cardWidth = 156.0;
        const spacing = 12.0;
        final columns = ((constraints.maxWidth + spacing) / (cardWidth + spacing))
            .floor()
            .clamp(1, 8);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Arrastra las tarjetas para cambiar el orden',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var i = 0; i < files.length; i++)
                  SizedBox(
                    width:
                        (constraints.maxWidth - spacing * (columns - 1)) / columns,
                    child: _DraggablePreviewCard(
                      file: files[i],
                      index: i,
                      cardWidth: cardWidth,
                      onRotate: () => onRotate(files[i].id),
                      onZoom: () => onZoom(files[i]),
                      onDelete: () => onDelete(files[i].id),
                      onDuplicate: () => onDuplicate(files[i].id),
                      onAccept: (draggedIndex) => onReorder(draggedIndex, i),
                    ),
                  ),
                SizedBox(
                  width:
                      (constraints.maxWidth - spacing * (columns - 1)) / columns,
                  child: _AddMoreCard(
                    onTap: () => onInsertAt(insertAt: files.length),
                    onReorderToEnd: files.isEmpty ? null : onReorderToEnd,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DraggablePreviewCard extends StatelessWidget {
  const _DraggablePreviewCard({
    required this.file,
    required this.index,
    required this.cardWidth,
    required this.onRotate,
    required this.onZoom,
    required this.onDelete,
    required this.onDuplicate,
    required this.onAccept,
  });

  final PdfFileItem file;
  final int index;
  final double cardWidth;
  final VoidCallback onRotate;
  final VoidCallback onZoom;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final ValueChanged<int> onAccept;

  bool _immediateDrag(BuildContext context) =>
      kIsWeb || !Responsive.isMobile(context);

  Widget _card({double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: PdfPreviewCard(
        width: cardWidth,
        file: file,
        orderNumber: index + 1,
        onRotate: onRotate,
        onZoom: onZoom,
        onDelete: onDelete,
        onDuplicate: onDuplicate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _card(),
        const SizedBox(height: 6),
        const _DragOrderHandleShell(),
      ],
    );

    final immediateDrag = _immediateDrag(context);
    final draggableBody = immediateDrag
        ? Draggable<int>(
            data: index,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              color: Colors.transparent,
              elevation: 10,
              borderRadius: BorderRadius.circular(14),
              child: _card(),
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: column,
            ),
            child: column,
          )
        : LongPressDraggable<int>(
            data: index,
            feedback: Material(
              color: Colors.transparent,
              elevation: 10,
              borderRadius: BorderRadius.circular(14),
              child: _card(),
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: column,
            ),
            child: column,
          );

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: isTarget ? const EdgeInsets.all(4) : EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isTarget
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            color: isTarget
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
          ),
          child: draggableBody,
        );
      },
    );
  }
}

class _DragOrderHandleShell extends StatefulWidget {
  const _DragOrderHandleShell();

  @override
  State<_DragOrderHandleShell> createState() => _DragOrderHandleShellState();
}

class _DragOrderHandleShellState extends State<_DragOrderHandleShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.35)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drag_indicator_rounded,
              size: 18,
              color: _hovered ? AppColors.primary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 4),
            Text(
              'Arrastrar',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _hovered
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMoreCard extends StatefulWidget {
  const _AddMoreCard({
    required this.onTap,
    this.onReorderToEnd,
  });

  final VoidCallback onTap;
  final void Function(int fromIndex)? onReorderToEnd;

  @override
  State<_AddMoreCard> createState() => _AddMoreCardState();
}

class _AddMoreCardState extends State<_AddMoreCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 196,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.05)
                : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 28,
                color: _hovered ? AppColors.primary : AppColors.textSecondaryLight,
              ),
              const SizedBox(height: 8),
              Text(
                widget.onReorderToEnd != null
                    ? 'Agregar o soltar aquí'
                    : 'Agregar PDF',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _hovered
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.onReorderToEnd == null) return card;

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => widget.onReorderToEnd!(details.data),
      builder: (context, candidate, rejected) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: candidate.isNotEmpty
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: card,
        );
      },
    );
  }
}

class _EmptyUploadArea extends StatelessWidget {
  const _EmptyUploadArea({
    required this.isDragging,
    required this.onPickFiles,
  });

  final bool isDragging;
  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.value(context: context, mobile: 20, desktop: 48),
          vertical: Responsive.value(context: context, mobile: 32, desktop: 48),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isWide ? 64 : 56,
                height: isWide ? 64 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  isDragging
                      ? Icons.file_download_rounded
                      : Icons.upload_file_rounded,
                  size: isWide ? 30 : 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isDragging ? 'Suelta tus PDFs aquí' : 'Sube tus archivos PDF',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Arrastra uno o varios documentos, o selecciónalos desde tu equipo. '
                'Verás una vista previa antes de combinar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.55,
                    ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Seleccionar PDFs',
                icon: Icons.folder_open_rounded,
                compact: true,
                onPressed: onPickFiles,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  _FeatureChip(
                    icon: Icons.lock_outline,
                    label: '100% privado',
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    icon: Icons.speed_rounded,
                    label: 'Sin registro',
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    icon: Icons.devices_rounded,
                    label: 'Procesamiento local',
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
