import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/modern_components.dart';
import '../../core/widgets/floating_components.dart';
import '../localization/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// Écran de selection de la langue.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return PlateScaffold(
      title: l10n.settingsLanguage,
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _LanguageOption(
            locale: const Locale('en'),
            label: 'English',
            nativeLabel: 'English',
            currentLocale: currentLocale,
            isDark: isDark,
            onTap: () => ref.read(localeProvider.notifier).set(const Locale('en')),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LanguageOption(
            locale: const Locale('fr'),
            label: 'Français',
            nativeLabel: 'Français',
            currentLocale: currentLocale,
            isDark: isDark,
            onTap: () => ref.read(localeProvider.notifier).set(const Locale('fr')),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LanguageOption(
            locale: const Locale('de'),
            label: 'Deutsch',
            nativeLabel: 'Deutsch',
            currentLocale: currentLocale,
            isDark: isDark,
            onTap: () => ref.read(localeProvider.notifier).set(const Locale('de')),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String label;
  final String nativeLabel;
  final Locale currentLocale;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.locale,
    required this.label,
    required this.nativeLabel,
    required this.currentLocale,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ModernCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: isSelected
          ? (isDark ? AppColors.primaryContainer : AppColors.primaryContainer)
          : null,
      borderColor: isSelected
          ? (isDark ? AppColors.primaryLight : AppColors.primary)
          : null,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerHigh),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _flag(locale.languageCode),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeLabel,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (label != nativeLabel)
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              size: 24,
            ),
        ],
      ),
    );
  }

  String _flag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      default:
        return '🌐';
    }
  }
}