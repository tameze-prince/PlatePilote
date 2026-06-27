import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/premium_components.dart';
import '../../../core/providers/theme_provider.dart';

/// Sélecteur de thème (clair / système / sombre).
class ProfileThemeSelector extends ConsumerWidget {
  const ProfileThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    String label;
    if (themeMode == ThemeMode.system) {
      label = 'Follows system appearance';
    } else if (themeMode == ThemeMode.dark) {
      label = 'Dark mode';
    } else {
      label = 'Light mode';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Row(
        children: [
          Icon(
            themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primaryAccentGreen,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: AppTypography.bodyLarge.copyWith(
                    color: PremiumTheme.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: PremiumTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode, size: 18)),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18)),
            ],
            selected: {themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) {
              ref.read(themeModeProvider.notifier).set(selection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}
