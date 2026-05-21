import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_elevation.dart';
import '../../core/widgets/modern_components.dart';
import '../../core/widgets/modern_animations.dart';
import '../../core/widgets/modern_app_shell.dart';
import '../../core/widgets/empty_state.dart';

/// Example screen demonstrating the new design system
class DesignSystemDemoScreen extends StatefulWidget {
  const DesignSystemDemoScreen({super.key});

  @override
  State<DesignSystemDemoScreen> createState() => _DesignSystemDemoScreenState();
}

class _DesignSystemDemoScreenState extends State<DesignSystemDemoScreen> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: ModernAppBar(
        title: Text(
          'Design System',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        showSearch: true,
        showNotifications: true,
        notificationCount: 3,
        actions: [
          IconButton(
            icon: Icon(
              _isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() => _isDark = !_isDark);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color palette
            _buildSectionTitle('Color Palette'),
            const SizedBox(height: AppSpacing.md),
            _buildColorPalette(),

            const SizedBox(height: AppSpacing.xl),

            // Typography
            _buildSectionTitle('Typography'),
            const SizedBox(height: AppSpacing.md),
            _buildTypographyDemo(),

            const SizedBox(height: AppSpacing.xl),

            // Cards
            _buildSectionTitle('Cards'),
            const SizedBox(height: AppSpacing.md),
            _buildCardsDemo(),

            const SizedBox(height: AppSpacing.xl),

            // Buttons
            _buildSectionTitle('Buttons'),
            const SizedBox(height: AppSpacing.md),
            _buildButtonsDemo(),

            const SizedBox(height: AppSpacing.xl),

            // Progress indicators
            _buildSectionTitle('Progress Indicators'),
            const SizedBox(height: AppSpacing.md),
            _buildProgressDemo(),

            const SizedBox(height: AppSpacing.xl),

            // Alerts
            _buildSectionTitle('Alerts'),
            const SizedBox(height: AppSpacing.md),
            _buildAlertsDemo(),

            const SizedBox(height: AppSpacing.xl),

            // Empty state
            _buildSectionTitle('Empty State'),
            const SizedBox(height: AppSpacing.md),
            EmptyState(
              icon: Icons.search_off,
              title: 'No results found',
              message: 'Try adjusting your search filters',
              actionLabel: 'Clear Filters',
              onAction: () {},
            ),

            const SizedBox(height: AppSpacing.xl),

            // Loading skeleton
            _buildSectionTitle('Loading Skeleton'),
            const SizedBox(height: AppSpacing.md),
            _buildSkeletonDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      title,
      style: AppTypography.headlineSmall.copyWith(
        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildColorPalette() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _buildColorChip(
          'Primary',
          isDark ? AppColors.primaryLight : AppColors.primary,
        ),
        _buildColorChip(
          'Secondary',
          isDark ? AppColors.secondaryLight : AppColors.secondary,
        ),
        _buildColorChip('Tertiary', AppColors.tertiary),
        _buildColorChip('Success', AppColors.success),
        _buildColorChip('Warning', AppColors.warning),
        _buildColorChip('Error', AppColors.error),
        _buildColorChip('Info', AppColors.info),
      ],
    );
  }

  Widget _buildColorChip(String label, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.darkBackground : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypographyDemo() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Large',
          style: AppTypography.displayLarge.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Display Medium',
          style: AppTypography.displayMedium.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Display Small',
          style: AppTypography.displaySmall.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Headline Large',
          style: AppTypography.headlineLarge.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Headline Medium',
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Headline Small',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Title Large',
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Title Medium',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Title Small',
          style: AppTypography.titleSmall.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Body Large',
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Body Medium',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Body Small',
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Label Large',
          style: AppTypography.labelLarge.copyWith(
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Label Medium',
          style: AppTypography.labelMedium.copyWith(
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Label Small',
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCardsDemo() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        ModernCard(
          title: 'Standard Card',
          subtitle: 'This is a standard card component',
          child: const Text('Card content goes here'),
        ),
        const SizedBox(height: AppSpacing.md),
        StatCard(
          icon: Icons.savings,
          label: 'Total Saved',
          value: '\$142.50',
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        ProgressCard(
          icon: Icons.account_balance_wallet,
          label: 'Weekly Budget',
          value: '\$256 / \$400',
          progress: 0.64,
          maxValue: 400,
        ),
        const SizedBox(height: AppSpacing.md),
        InfoCard(
          icon: Icons.eco,
          title: 'Pantry Optimization',
          description: 'Use what you have first to reduce waste',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ],
    );
  }

  Widget _buildButtonsDemo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Primary'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: const Text('Tertiary'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AnimatedButton(
                onPressed: () {},
                child: const Text('Animated'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressDemo() {
    return Column(
      children: [
        AnimatedProgressIndicator(value: 0.64, minHeight: 8),
        const SizedBox(height: AppSpacing.md),
        AnimatedProgressIndicator(
          value: 0.32,
          minHeight: 8,
          valueColor: AppColors.secondary,
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedProgressIndicator(
          value: 0.85,
          minHeight: 8,
          valueColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildAlertsDemo() {
    return Column(
      children: [
        AlertCard(
          type: AlertType.success,
          title: 'Success',
          message: 'Your meal plan has been saved successfully',
        ),
        const SizedBox(height: AppSpacing.md),
        AlertCard(
          type: AlertType.warning,
          title: 'Warning',
          message: 'Your budget is 80% used for this week',
        ),
        const SizedBox(height: AppSpacing.md),
        AlertCard(
          type: AlertType.error,
          title: 'Error',
          message: 'Failed to sync with server. Please try again',
          actions: [TextButton(onPressed: () {}, child: const Text('Retry'))],
        ),
        const SizedBox(height: AppSpacing.md),
        AlertCard(
          type: AlertType.info,
          title: 'Information',
          message: 'New recipes are available based on your preferences',
        ),
      ],
    );
  }

  Widget _buildSkeletonDemo() {
    return Column(
      children: [
        Row(
          children: [
            const LoadingSkeleton(
              height: 48,
              width: 48,
              borderRadius: AppRadius.full,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingSkeleton(height: 16, width: double.infinity),
                  const SizedBox(height: AppSpacing.xs),
                  const LoadingSkeleton(height: 12, width: 120),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const LoadingSkeleton(
          height: 100,
          width: double.infinity,
          borderRadius: AppRadius.card,
        ),
      ],
    );
  }
}
