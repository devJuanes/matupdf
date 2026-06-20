import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/matudb/matudb_config.dart';
import '../../../../shared/layout/content_container.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_header.dart';
import '../widgets/merge_history_panel.dart';
import '../controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    this.initialRegister = false,
    this.redirectTo,
    this.mergeAfterAuth = false,
  });

  final bool initialRegister;
  final String? redirectTo;
  final bool mergeAfterAuth;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialRegister ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (auth.isAuthenticated) {
      return _AuthenticatedView(
        userName: auth.user!.displayName,
        userId: auth.user!.id,
        onContinue: () => _goAfterAuth(context),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(onBack: () => _goBack(context)),
      body: SingleChildScrollView(
        child: ContentContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tu cuenta MatuPDF',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Solo correo y contraseña. Tu sesión se guarda '
                        'automáticamente para que puedas descargar cuando vuelvas.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                      if (!MatuDbConfig.isConfigured) ...[
                        const SizedBox(height: 16),
                        _InfoBanner(
                          icon: Icons.info_outline,
                          text:
                              'MatuDB no está configurado. Define MATUDB_URL y '
                              'MATUDB_API_KEY al compilar.',
                          color: AppColors.warning,
                        ),
                      ],
                      const SizedBox(height: 24),
                      TabBar(
                        controller: _tabs,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondaryLight,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: 'Iniciar sesión'),
                          Tab(text: 'Crear cuenta'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (auth.errorMessage != null) ...[
                        _InfoBanner(
                          icon: Icons.error_outline,
                          text: auth.errorMessage!,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        height: 260,
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _LoginForm(
                              formKey: _loginFormKey,
                              email: _loginEmail,
                              password: _loginPassword,
                              isLoading: auth.isLoading,
                              onSubmit: () => _signIn(auth),
                            ),
                            _RegisterForm(
                              formKey: _registerFormKey,
                              email: _registerEmail,
                              password: _registerPassword,
                              isLoading: auth.isLoading,
                              onSubmit: () => _signUp(auth),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    final redirect = widget.redirectTo;
    if (redirect != null && redirect.startsWith('/')) {
      context.go(redirect);
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _goAfterAuth(BuildContext context) {
    final redirect = widget.redirectTo;
    if (redirect != null && redirect.startsWith('/')) {
      if (widget.mergeAfterAuth && redirect == AppRoutes.merge) {
        context.go('${AppRoutes.merge}?merge=1');
      } else {
        context.go(redirect);
      }
      return;
    }
    context.go(AppRoutes.merge);
  }

  Future<void> _signIn(AuthController auth) async {
    if (!_loginFormKey.currentState!.validate()) return;
    auth.clearError();
    final ok = await auth.signIn(
      email: _loginEmail.text,
      password: _loginPassword.text,
    );
    if (ok && mounted) _goAfterAuth(context);
  }

  Future<void> _signUp(AuthController auth) async {
    if (!_registerFormKey.currentState!.validate()) return;
    auth.clearError();
    final ok = await auth.signUp(
      email: _registerEmail.text,
      password: _registerPassword.text,
    );
    if (ok && mounted) _goAfterAuth(context);
  }
}

class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({
    required this.userName,
    required this.userId,
    required this.onContinue,
  });

  final String userName;
  final String userId;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(onBack: () => context.go(AppRoutes.home)),
      body: SingleChildScrollView(
        child: ContentContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              userName.characters.first.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, $userName!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  auth.user?.email ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (auth.isSessionExpired) ...[
                        const SizedBox(height: 16),
                        _InfoBanner(
                          icon: Icons.info_outline,
                          text:
                              'Tu sesión expiró. Si algo falla, cierra sesión e ingresa de nuevo.',
                          color: AppColors.warning,
                        ),
                      ],
                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 20),
                      MergeHistoryPanel(userId: userId),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Ir a combinar PDFs',
                        icon: Icons.merge_type_rounded,
                        compact: true,
                        isExpanded: true,
                        onPressed: onContinue,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: auth.signOut,
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: _emailValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
          ),
          const Spacer(),
          AppButton(
            label: isLoading ? 'Entrando…' : 'Iniciar sesión',
            icon: Icons.login_rounded,
            compact: true,
            isExpanded: true,
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: _emailValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
          ),
          const Spacer(),
          AppButton(
            label: isLoading ? 'Creando cuenta…' : 'Crear cuenta',
            icon: Icons.person_add_alt_1_rounded,
            compact: true,
            isExpanded: true,
            isLoading: isLoading,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

String? _emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
  if (!value.contains('@')) return 'Correo inválido';
  return null;
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
