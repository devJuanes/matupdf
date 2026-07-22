import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_button.dart';
import '../../domain/signature_capture_stub.dart'
    if (dart.library.html) '../../domain/signature_capture_web.dart';

class SignaturePadDialog extends StatefulWidget {
  const SignaturePadDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const SignaturePadDialog(),
    );
  }

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  final _points = <Offset?>[];
  static const _padSize = Size(420, 160);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dibuja tu firma'),
      content: SizedBox(
        width: _padSize.width,
        height: _padSize.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: GestureDetector(
            onPanStart: (d) => setState(() => _points.add(d.localPosition)),
            onPanUpdate: (d) => setState(() => _points.add(d.localPosition)),
            onPanEnd: (_) => setState(() => _points.add(null)),
            child: CustomPaint(
              painter: _SignaturePainter(_points),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _points.clear()),
          child: const Text('Limpiar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        AppButton(
          label: 'Usar firma',
          compact: true,
          onPressed: _points.whereType<Offset>().length < 2
              ? null
              : () {
                  final mapped = _points
                      .map(
                        (p) => p == null
                            ? <String, double?>{'x': null, 'y': null}
                            : <String, double?>{'x': p.dx, 'y': p.dy},
                      )
                      .toList();
                  final dataUrl = signaturePointsToPngDataUrl(
                    mapped,
                    width: _padSize.width,
                    height: _padSize.height,
                  );
                  Navigator.pop(context, dataUrl);
                },
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a != null && b != null) canvas.drawLine(a, b, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
