import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_header.dart';
import '../../../../widgets/app_nav.dart';
import '../../../../widgets/corporate_footer.dart';
import '../sections/benefits_section.dart';
import '../sections/faq_section.dart';
import '../sections/features_section.dart';
import '../sections/hero_section.dart';
import '../sections/how_it_works_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _goToMerge(BuildContext context) => context.go(AppRoutes.merge);

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).uri.path;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          LandingAppHeader(
            navLinks: [
              AppNav(currentRoute: route),
            ],
          ),
          SliverToBoxAdapter(
            child: HeroSection(
              onSelectPdfs: () => _goToMerge(context),
              onScrollToMerge: () => _goToMerge(context),
            ),
          ),
          const SliverToBoxAdapter(child: FeaturesSection()),
          const SliverToBoxAdapter(child: BenefitsSection()),
          const SliverToBoxAdapter(child: HowItWorksSection()),
          const SliverToBoxAdapter(child: FaqSection()),
          const SliverToBoxAdapter(child: CorporateFooter()),
        ],
      ),
    );
  }
}
