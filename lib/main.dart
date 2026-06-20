import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_notifier.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/home/presentation/controllers/merge_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final authController = AuthController();
  await authController.initialize();
  runApp(MatuPdfApp(authController: authController));
}

class MatuPdfApp extends StatefulWidget {
  const MatuPdfApp({super.key, required this.authController});

  final AuthController authController;

  @override
  State<MatuPdfApp> createState() => _MatuPdfAppState();
}

class _MatuPdfAppState extends State<MatuPdfApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController;
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider.value(value: _authController),
        ChangeNotifierProvider(create: (_) => MergeController()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp.router(
            title: AppConstants.seoTitle,
            debugShowCheckedModeBanner: false,
            themeMode: themeNotifier.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
