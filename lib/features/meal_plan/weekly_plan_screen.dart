import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/color_tokens.dart';
import '../../app/theme/spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/meal_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/widgets/plate_scaffold.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return PlateScaffold(
      title: 'PlatePilot',
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.calendar_month_outlined),
      ),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Your Week', style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '7 balanced meals selected for your household.',
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isTablet && screenWidth >= 900)
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      title: 'Quick Meal',
                      subtitle: 'Express mode',
                      icon: Icons.bolt,
                      color: ColorTokens.primaryGreen,
                      onTap: () => context.push('/quick-meal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ActionTile(
                      title: 'Grocery List',
                      subtitle: 'Ready to buy',
                      icon: Icons.shopping_cart_outlined,
                      color: ColorTokens.accentAmber,
                      onTap: () => context.go('/grocery'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ActionTile(
                      title: 'Regenerate',
                      subtitle: 'Refresh plan',
                      icon: Icons.refresh,
                      color: ColorTokens.accentBlue,
                      onTap: () {},
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      title: 'Quick Meal',
                      subtitle: 'Express mode',
                      icon: Icons.bolt,
                      color: ColorTokens.primaryGreen,
                      onTap: () => context.push('/quick-meal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ActionTile(
                      title: 'Grocery List',
                      subtitle: 'Ready to buy',
                      icon: Icons.shopping_cart_outlined,
                      color: ColorTokens.accentAmber,
                      onTap: () => context.go('/grocery'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            ...demoMeals.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: MealCard(
                  meal: entry.$2,
                  onTap: () => context.push('/recipe/${entry.$1}'),
                ),
              ),
            ),
            AppCard(
              color: context.isDark
                  ? ColorTokens.darkElevatedSurface
                  : ColorTokens.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Budget',
                    style: context.text.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    r'$142.85 for 24 grocery items, including 8 pantry ingredients already on hand.',
                    style: context.text.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Replace',
                          icon: Icons.swap_horiz,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Meal replaced')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Regenerate',
                          icon: Icons.refresh,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Weekly plan regenerated!'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: color == ColorTokens.primaryGreen ? color : null,
      child: SizedBox(
        height: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: color == ColorTokens.primaryGreen ? Colors.white : color,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.bodyLarge?.copyWith(
                    color: color == ColorTokens.primaryGreen
                        ? Colors.white
                        : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.text.labelSmall?.copyWith(
                    color: color == ColorTokens.primaryGreen
                        ? Colors.white70
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
