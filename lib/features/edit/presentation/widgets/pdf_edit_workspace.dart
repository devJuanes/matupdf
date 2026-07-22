import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_button.dart';
import '../controllers/edit_controller.dart';
import 'pdf_edit_toolbar.dart';
import 'pdf_page_canvas.dart';
import 'signature_pad_dialog.dart';
import '../../data/models/pdf_annotation.dart';

class PdfEditWorkspace extends StatefulWidget {
  const PdfEditWorkspace({super.key});

  @override
  State<PdfEditWorkspace> createState() => _PdfEditWorkspaceState();
}

class _PdfEditWorkspaceState extends State<PdfEditWorkspace> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EditController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        if (details.files.isEmpty) return;
        final file = details.files.first;
        if (!file.name.toLowerCase().endsWith('.pdf')) return;
        if (kIsWeb) {
          await controller.loadFromPath(name: file.name, path: file.path);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: _dragging
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: _dragging ? 2 : 1,
          ),
          boxShadow: AppColors.cardShadow(isDark: isDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: !controller.hasFile
            ? _EmptyState(
                isDragging: _dragging,
                onPick: controller.pickPdf,
              )
            : Column(
                children: [
                  PdfEditToolbar(controller: controller),
                  if (controller.errorMessage != null)
                    Material(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 18),
                        title: Text(
                          controller.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: controller.clearError,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Row(
                      children: [
                        if (controller.showThumbnails)
                          _ThumbnailsRail(controller: controller),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PdfPageCanvas(
                                    controller: controller,
                                    onRequestText: () => _askText(context),
                                    onRequestSignature: () =>
                                        SignaturePadDialog.show(context),
                                    onRequestImage: () => _pickImage(context),
                                    onEditExistingText: (item, current) =>
                                        _editExistingText(context, current),
                                  ),
                                ),
                              ),
                              _PageFooter(controller: controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<String?> _askText(BuildContext context) async {
    final field = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir texto'),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Escribe el texto…',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          AppButton(
            label: 'Agregar',
            compact: true,
            onPressed: () => Navigator.pop(ctx, field.text),
          ),
        ],
      ),
    );
  }

  Future<String?> _editExistingText(BuildContext context, String current) async {
    final field = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar texto'),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Texto del PDF',
            border: OutlineInputBorder(),
            helperText: 'Se reemplazará el texto original en esta posición.',
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          AppButton(
            label: 'Guardar',
            compact: true,
            onPressed: () => Navigator.pop(ctx, field.text),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;
    final mime = file.extension?.toLowerCase() == 'png'
        ? 'image/png'
        : 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDragging, required this.onPick});

  final bool isDragging;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_document,
              size: 56,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              isDragging ? 'Suelta tu PDF aquí' : 'Edita un PDF',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade texto, firma, imágenes, resaltados y más.\n'
              'Luego descarga el PDF editado.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Seleccionar PDF',
              icon: Icons.upload_file_rounded,
              onPressed: onPick,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailsRail extends StatelessWidget {
  const _ThumbnailsRail({required this.controller});

  final EditController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 120,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: controller.pageCount,
        itemBuilder: (context, index) {
          final selected = index == controller.currentPage;
          final thumb = controller.pageImage(index);
          if (thumb == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.ensurePageLoaded(index);
            });
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => controller.selectPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 0.7,
                      child: thumb == null
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : Image.network(thumb, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.primary : null,
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

class _PageFooter extends StatelessWidget {
  const _PageFooter({required this.controller});

  final EditController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Página anterior',
            onPressed: controller.currentPage > 0
                ? () => controller.selectPage(controller.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            'Página ${controller.currentPage + 1} / ${controller.pageCount}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          IconButton(
            tooltip: 'Página siguiente',
            onPressed: controller.currentPage < controller.pageCount - 1
                ? () => controller.selectPage(controller.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Alejar',
                  onPressed: controller.zoom <= 0.5 ? null : controller.zoomOut,
                  icon: const Icon(Icons.remove_rounded, size: 18),
                ),
                InkWell(
                  onTap: controller.resetZoom,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${(controller.zoom * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Acercar',
                  onPressed: controller.zoom >= 3 ? null : controller.zoomIn,
                  icon: const Icon(Icons.add_rounded, size: 18),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (controller.tool == EditTool.editText)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Clic en el texto resaltado para editarlo',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (controller.selectedAnnotationId != null)
            TextButton.icon(
              onPressed: controller.removeSelected,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar'),
            ),
          const SizedBox(width: 8),
          AppButton(
            label: controller.isExporting ? 'Exportando…' : 'Descargar PDF',
            icon: Icons.download_rounded,
            compact: true,
            isLoading: controller.isExporting,
            onPressed: controller.isExporting ? null : controller.exportPdf,
          ),
        ],
      ),
    );
  }
}
