import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/design_system/components/pp_button.dart';

/// Construit les boutons d'actions rapides.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PpButton(
            label: 'Plan Week',
            icon: Icons.calendar_month,
            variant: PpButtonVariant.primary,
            onPressed: () => context.push('/plan'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PpButton(
            label: 'Add Items',
            icon: Icons.add_shopping_cart,
            variant: PpButtonVariant.primary,
            onPressed: () => context.push('/grocery/add'),
          ),
        ),
      ],
    );
  }
}
