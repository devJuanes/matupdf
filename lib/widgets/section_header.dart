import 'package:flutter/material.dart';

import '../core/utils/responsive.dart';
import 'animated_fade_in.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.alignment = CrossAxisAlignment.center,
  });

  final String title;
  final String subtitle;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final isCenter = alignment == CrossAxisAlignment.center;

    return AnimatedFadeIn(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            title,
            textAlign: isCenter ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: Responsive.value(
                    context: context,
                    mobile: 28,
                    desktop: 36,
                  ),
                ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context) ? double.infinity : 560,
            ),
            child: Text(
              subtitle,
              textAlign: isCenter ? TextAlign.center : TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
