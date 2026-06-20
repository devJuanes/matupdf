import 'package:flutter/material.dart';

import '../../../../core/utils/open_url.dart';
import '../../../../theme/app_colors.dart';
import '../../../home/data/merge_history_repository.dart';

class MergeHistoryPanel extends StatefulWidget {
  const MergeHistoryPanel({super.key, required this.userId});

  final String userId;

  @override
  State<MergeHistoryPanel> createState() => _MergeHistoryPanelState();
}

class _MergeHistoryPanelState extends State<MergeHistoryPanel> {
  final _repository = MergeHistoryRepository();
  List<MergeHistoryEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _repository.fetchForUser(widget.userId);
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _entries = result.data ?? [];
      } else {
        _error = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Historial de PDFs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Actualizar',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_error != null)
          _MessageBox(
            icon: Icons.error_outline,
            text: _error!,
            color: AppColors.primary,
          )
        else if (_entries.isEmpty)
          _MessageBox(
            icon: Icons.history_rounded,
            text: 'Aún no tienes combinaciones guardadas. '
                'Combina PDFs estando logueado para verlas aquí.',
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return _HistoryTile(entry: entry, isDark: isDark);
            },
          ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.isDark});

  final MergeHistoryEntry entry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt != null
        ? _formatDate(entry.createdAt!.toLocal())
        : 'Fecha desconocida';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.fileCount} PDF${entry.fileCount == 1 ? '' : 's'} combinados',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (entry.fileUrl != null)
                TextButton.icon(
                  onPressed: () => openExternalUrl(entry.fileUrl!),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Descargar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
          ),
          if (entry.fileNames != null && entry.fileNames!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              entry.fileNames!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d/$m/${dt.year} $h:$min';
}
