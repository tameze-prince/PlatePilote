import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/design_system/components/pp_scaffold.dart';
import '../../core/widgets/floating_components.dart';
import '../search/command_palette/pp_command_palette.dart';
import 'home_provider.dart';
import 'widgets/home_dashboard.dart';
import 'widgets/home_loading_state.dart';

/// Écran d'accueil principal.
/// Affiche le tableau de bord avec les recommandations, le budget, le garde-manger et la liste de courses.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Recharge les données du tableau de bord.
  Future<void> _onRefresh() async {
    await ref.read(homeProvider.notifier).loadHome();
  }

  /// Retourne l'initiale pour l'avatar utilisateur.
  String _avatarInitial(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'P';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = homeState.isLoading;

    return PpScaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: FloatingAppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDark
                          ? AppColors.darkPrimaryContainer
                          : AppColors.primaryContainer,
                      child: Text(
                        _avatarInitial(homeState.dashboard?.firstName),
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'PlatePilot',
                      style: AppTypography.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search),
                    onPressed: () => PpCommandPalette.show<void>(context),
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: FloatingSearchBar(
                hintText: 'Search recipes, ingredients...',
                onTap: () => context.push('/search'),
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? const HomeLoadingState()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        100,
                      ),
                      child: HomeDashboard(
                        state: homeState,
                        isDark: isDark,
                      ),
                    ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }
}
