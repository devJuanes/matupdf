import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/responsive.dart';
import '../shared/layout/content_container.dart';
import '../features/support/voluntary_tip_link.dart';
import '../theme/app_colors.dart';
import 'logo.dart';

class CorporateFooter extends StatelessWidget {
  const CorporateFooter({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF111827),
            Color(0xFF0B1120),
          ],
        ),
      ),
      child: ContentContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 32 : Responsive.value(
              context: context,
              mobile: 48,
              desktop: 64,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile || compact)
                _MobileLayout(compact: compact)
              else
                _DesktopLayout(compact: compact),
              const SizedBox(height: 36),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const VoluntaryTipLink(lightOnDark: true, compact: true),
              const SizedBox(height: 8),
              _BottomBar(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _BrandColumn()),
        const SizedBox(width: 48),
        Expanded(flex: 3, child: _LinksColumn(title: 'Producto')),
        const SizedBox(width: 32),
        Expanded(flex: 3, child: _LinksColumn(title: 'Legal')),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: _ContactColumn()),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        const SizedBox(height: 32),
        _LinksColumn(title: 'Producto'),
        const SizedBox(height: 28),
        _LinksColumn(title: 'Legal'),
        const SizedBox(height: 28),
        _ContactColumn(),
      ],
    );
  }
}

class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MatuLogo(height: 40),
        const SizedBox(height: 16),
        Text(
          AppConstants.appDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.6,
              ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Procesamiento 100% local y privado',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinksColumn extends StatelessWidget {
  const _LinksColumn({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final links = title == 'Producto'
        ? const [
            ('Características', null),
            ('Cómo funciona', null),
            ('Preguntas frecuentes', null),
            ('Combinar PDFs', AppRoutes.merge),
            ('Editar PDF', AppRoutes.edit),
          ]
        : [
            ('Política de privacidad', AppRoutes.privacy),
            ('Términos de servicio', AppRoutes.terms),
            ('Contacto', AppRoutes.contact),
            ('Crear cuenta', AppRoutes.account),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 16),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FooterLink(
              label: link.$1,
              route: link.$2,
            ),
          ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacto',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 16),
        _ContactItem(
          icon: Icons.business_outlined,
          label: 'Empresa',
          value: AppConstants.companyLegalName,
        ),
        _ContactItem(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: AppConstants.contactEmail,
          copyable: true,
        ),
        _ContactItem(
          icon: Icons.support_agent_outlined,
          label: 'Soporte',
          value: AppConstants.supportEmail,
          copyable: true,
        ),
        _ContactItem(
          icon: Icons.language_outlined,
          label: 'Web',
          value: AppConstants.companyWebsite.replaceFirst('https://', ''),
          copyable: true,
        ),
        _ContactItem(
          icon: Icons.location_on_outlined,
          label: 'País',
          value: AppConstants.companyCountry,
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.85)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: copyable
                      ? () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$label copiado al portapapeles'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          decoration: copyable ? TextDecoration.underline : null,
                          decorationColor: Colors.white.withValues(alpha: 0.3),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _copyright(context),
              const SizedBox(height: 8),
              _developer(context),
            ],
          )
        : Row(
            children: [
              Expanded(child: _copyright(context)),
              _developer(context),
            ],
          );
  }

  Widget _copyright(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} ${AppConstants.appName}. Todos los derechos reservados.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
          ),
    );
  }

  Widget _developer(BuildContext context) {
    return Text(
      'Desarrollado por ${AppConstants.companyName}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, this.route});

  final String label;
  final String? route;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.route != null
            ? () => context.go(widget.route!)
            : null,
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: _hovered ? 1 : 0.65),
                decoration: _hovered ? TextDecoration.underline : null,
                decorationColor: AppColors.primary.withValues(alpha: 0.6),
              ),
        ),
      ),
    );
  }
}
