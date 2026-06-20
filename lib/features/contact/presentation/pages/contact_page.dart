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
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/contact_repository.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  final _repository = ContactRepository();
  bool _isSending = false;
  bool _sent = false;
  String? _error;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    final auth = context.read<AuthController>();
    if (auth.isAuthenticated) {
      _email.text = auth.user!.email;
      if (auth.user!.name != null && auth.user!.name!.trim().isNotEmpty) {
        _name.text = auth.user!.name!.trim();
      }
    }
    _prefilled = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(onBack: () => context.go(AppRoutes.home)),
      body: SingleChildScrollView(
        child: ContentContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AppCard(
                  child: _sent ? _SuccessView(onBack: () => context.go(AppRoutes.home)) : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Contáctanos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Tienes dudas, sugerencias o necesitas soporte? '
                        'Escríbenos y te responderemos pronto.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppConstants.companyLegalName} · ${AppConstants.contactEmail}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (!MatuDbConfig.isConfigured) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Formulario desactivado: configura MatuDB.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                              ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_error!, style: TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Requerido';
                                if (!v.contains('@')) return 'Correo inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _subject,
                              decoration: const InputDecoration(
                                labelText: 'Asunto',
                                prefixIcon: Icon(Icons.subject_outlined),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _message,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Mensaje',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.chat_bubble_outline),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().length < 10)
                                      ? 'Mínimo 10 caracteres'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: _isSending ? 'Enviando…' : 'Enviar mensaje',
                        icon: Icons.send_rounded,
                        compact: true,
                        isExpanded: true,
                        isLoading: _isSending,
                        onPressed: _isSending || !MatuDbConfig.isConfigured
                            ? null
                            : _submit,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _error = null;
    });

    final auth = context.read<AuthController>();
    final result = await _repository.submit(
      name: _name.text,
      email: _email.text,
      subject: _subject.text,
      message: _message.text,
      userId: auth.isAuthenticated ? auth.user!.id : null,
    );

    if (!mounted) return;

    setState(() {
      _isSending = false;
      if (result.isSuccess) {
        _sent = true;
      } else {
        _error = result.error ?? 'No se pudo enviar el mensaje';
      }
    });
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: AppColors.success),
        const SizedBox(height: 16),
        Text(
          '¡Mensaje enviado!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gracias por contactarnos. Te responderemos lo antes posible.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Volver al inicio',
          icon: Icons.home_outlined,
          compact: true,
          onPressed: onBack,
        ),
      ],
    );
  }
}
