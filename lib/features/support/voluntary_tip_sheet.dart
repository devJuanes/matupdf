import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/payments/paymatubyte_config.dart';
import '../../core/payments/paymatubyte_service.dart';
import '../../core/utils/open_url.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

/// Apoyo voluntario — no bloquea el flujo principal.
class VoluntaryTipSheet extends StatefulWidget {
  const VoluntaryTipSheet({super.key});

  static Future<void> show(BuildContext context) {
    if (!PayMatuByteConfig.isConfigured) {
      return Future.value();
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: VoluntaryTipSheet(),
      ),
    );
  }

  @override
  State<VoluntaryTipSheet> createState() => _VoluntaryTipSheetState();
}

class _VoluntaryTipSheetState extends State<VoluntaryTipSheet> {
  static const _suggested = [3000, 5000, 10000];

  final _customController = TextEditingController();
  int? _selected;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _amount {
    final custom = int.tryParse(_customController.text.replaceAll('.', ''));
    if (custom != null && custom >= 1000) return custom;
    return _selected;
  }

  Future<void> _pay() async {
    final amount = _amount;
    if (amount == null) {
      setState(() => _error = 'Elige o escribe un monto (mín. \$1.000)');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = await PayMatuByteService.createVoluntaryTipLink(
        amountCop: amount,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      openExternalUrl(url);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No pudimos abrir el pago. Intenta más tarde.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Invítame un café',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'MatuPDF es gratis. Si te sirvió, puedes dejar un aporte voluntario — '
            'tú eliges el monto.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggested.map((amount) {
              final selected = _selected == amount;
              return ChoiceChip(
                label: Text('\$${_formatCop(amount)}'),
                selected: selected,
                onSelected: _loading
                    ? null
                    : (v) {
                        setState(() {
                          _selected = v ? amount : null;
                          _customController.clear();
                          _error = null;
                        });
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customController,
            enabled: !_loading,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Otro monto (COP)',
              hintText: 'Ej. 15000',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) {
              setState(() {
                _selected = null;
                _error = null;
              });
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: 'Continuar al pago',
            icon: Icons.coffee_rounded,
            isExpanded: true,
            isLoading: _loading,
            onPressed: _loading ? null : _pay,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: const Text('Ahora no, gracias'),
          ),
        ],
      ),
    );
  }

  String _formatCop(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
