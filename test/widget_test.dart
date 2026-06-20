import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:matupdf/features/auth/presentation/controllers/auth_controller.dart';
import 'package:matupdf/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MatuPDF app loads landing page', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final authController = AuthController();
    await authController.initialize();
    await tester.pumpWidget(MatuPdfApp(authController: authController));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.textContaining('Combina PDFs'), findsOneWidget);
    expect(find.text('Seleccionar PDFs'), findsWidgets);
  });
}
