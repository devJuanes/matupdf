import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/payments/payment_return_info.dart';
import '../../../core/utils/responsive.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../data/donation_repository.dart';
import 'confetti_overlay.dart';

class DonationThankYouDialog extends StatefulWidget {
  const DonationThankYouDialog({super.key, required this.payment});

  final PaymentReturnInfo payment;

  static Future<void> show(BuildContext context, PaymentReturnInfo payment) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => DonationThankYouDialog(payment: payment),
    );
  }

  @override
  State<DonationThankYouDialog> createState() => _DonationThankYouDialogState();
}

class _DonationThankYouDialogState extends State<DonationThankYouDialog> {
  final _emailController = TextEditingController();
  final _repo = DonationRepository();
  bool _saving = false;
  String? _error;
  bool _saved = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final auth = context.read<AuthController>();
    final result = await _repo.saveGreetingEmail(
      reference: widget.payment.reference,
      email: email,
      userId: auth.user?.id,
    );

    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        _saving = false;
        _error = result.error ?? 'No pudimos guardar tu correo';
      });
      return;
    }

    setState(() {
      _saving = false;
      _saved = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.value(
      context: context,
      mobile: MediaQuery.sizeOf(context).width - 32,
      desktop: 460.0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned.fill(child: ConfettiOverlay()),
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.success.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¡Mil gracias!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.payment.isPaid
                        ? 'Tu apoyo voluntario ayuda a mantener ${AppConstants.appName} '
                            'gratis para todos. De verdad, lo apreciamos.'
                        : 'Recibimos tu intento de apoyo. Si el pago quedó pendiente, '
                            'puedes intentarlo de nuevo cuando quieras.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.55,
                        ),
                  ),
                  if (widget.payment.isPaid) ...[
                    const SizedBox(height: 24),
                    Text(
                      '¿Quieres dejarnos tu correo? Te enviaremos un saludo de agradecimiento.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      enabled: !_saving && !_saved,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: 'Correo (opcional)',
                        hintText: 'tu@correo.com',
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                    if (_saved) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '¡Listo! Te escribiremos pronto.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      label: _saved ? 'Cerrar' : 'Enviar saludo',
                      icon: Icons.send_rounded,
                      isExpanded: true,
                      isLoading: _saving,
                      onPressed: _saved
                          ? () => Navigator.of(context).pop()
                          : _saveEmail,
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Continuar sin correo'),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Entendido',
                      isExpanded: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
