import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_header.dart';
import '../../../../widgets/auth_nav_button.dart';
import '../controllers/edit_controller.dart';
import '../widgets/pdf_edit_workspace.dart';

class EditPage extends StatelessWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppHeader(
        variant: AppHeaderVariant.workspace,
        onBack: () => context.go(AppRoutes.home),
        actions: const [AuthNavButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.value(context: context, mobile: 12, desktop: 24),
                0,
                Responsive.value(context: context, mobile: 12, desktop: 24),
                Responsive.value(context: context, mobile: 12, desktop: 20),
              ),
              child: const PdfEditWorkspace(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<EditController>();

    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.value(context: context, mobile: 16, desktop: 28),
        16,
        Responsive.value(context: context, mobile: 16, desktop: 28),
        18,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editar PDF',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.hasFile
                ? controller.file!.name
                : 'Añade texto, firma, imágenes y anotaciones. Todo en tu navegador.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}
