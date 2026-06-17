import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_animations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/pp_skeleton.dart';
import '../../../core/premium_components.dart';
import '../../../l10n/app_localizations.dart';
import 'command_palette_provider.dart';
import 'command_palette_result_item.dart';

/// Standalone screen hosting the command palette.
///
/// Lives at `/command-palette` and is presented as a near-fullscreen
/// route (no bottom-sheet detent) so it feels native to cmd-K UX from
/// Linear / Notion / Vercel. The actual trigger is exposed through
/// [PpCommandPalette.show].
class CommandPaletteScreen extends ConsumerStatefulWidget {
  const CommandPaletteScreen({super.key});

  @override
  ConsumerState<CommandPaletteScreen> createState() =>
      _CommandPaletteScreenState();
}

class _CommandPaletteScreenState extends ConsumerState<CommandPaletteScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int _highlight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _inputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _closePalette() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    }
  }

  void _onQueryChanged(String value) {
    ref.read(commandPaletteProvider.notifier).setQuery(value);
    ref.read(commandPaletteProvider.notifier).runSearch(value);
    setState(() => _highlight = 0);
  }

  void _activate(CommandPaletteResult result) {
    if (result.payload != null) {
      context.push(result.route, extra: result.payload);
    } else {
      context.push(result.route);
    }
  }

  void _moveHighlight(int delta) {
    final state = ref.read(commandPaletteProvider);
    final flat = state.flattened;
    if (flat.isEmpty) return;
    setState(() {
      _highlight = (_highlight + delta).clamp(0, flat.length - 1);
    });
  }

  void _activateHighlighted() {
    final flat = ref.read(commandPaletteProvider).flattened;
    if (flat.isEmpty) return;
    final index = _highlight.clamp(0, flat.length - 1);
    _activate(flat[index]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(commandPaletteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): _closePalette,
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _moveHighlight(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _moveHighlight(-1),
        const SingleActivator(LogicalKeyboardKey.enter): _activateHighlighted,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _PaletteBackdrop(
            isDark: isDark,
            onTap: _closePalette,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _PalettePanel(
                    isDark: isDark,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PaletteInput(
                          controller: _controller,
                          focusNode: _inputFocus,
                          hintText: l10n.cmdPaletteSearchHint,
                          isDark: isDark,
                          onChanged: _onQueryChanged,
                          onSubmitted: (_) => _activateHighlighted(),
                          onClose: _closePalette,
                          closeTooltip: l10n.cmdPaletteCloseHint,
                        ),
                        Flexible(
                          child: _PaletteBody(
                            state: state,
                            isDark: isDark,
                            highlight: _highlight,
                            onHighlightChanged: (i) =>
                                setState(() => _highlight = i),
                            scrollController: _scrollController,
                            onActivate: _activate,
                          ),
                        ),
                        if (state.query.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              0,
                              AppSpacing.md,
                              AppSpacing.sm,
                            ),
                            child: Text(
                              l10n.cmdPaletteCloseHint,
                              textAlign: TextAlign.center,
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.darkOnSurfaceTertiary
                                    : AppColors.onSurfaceTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades background scrim in/out.
class _PaletteBackdrop extends StatefulWidget {
  const _PaletteBackdrop({
    required this.child,
    required this.onTap,
    required this.isDark,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_PaletteBackdrop> createState() => _PaletteBackdropState();
}

class _PaletteBackdropState extends State<_PaletteBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppAnimations.small,
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppAnimations.easeOutEmphasized,
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.96, end: 1.0)
      .animate(CurvedAnimation(
    parent: _controller,
    curve: AppAnimations.easeOutEmphasized,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _fade,
              builder: (context, _) {
                return Container(
                  color: Colors.black.withValues(alpha: 0.6 * _fade.value),
                );
              },
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Container for the panel content with elevation + border.
class _PalettePanel extends StatelessWidget {
  const _PalettePanel({required this.child, required this.isDark});

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: PremiumTheme.floatingShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkElevatedSurface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: PremiumTheme.border(context)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Top input row.
class _PaletteInput extends StatelessWidget {
  const _PaletteInput({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClose,
    required this.closeTooltip,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClose;
  final String closeTooltip;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final secondary =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 22, color: secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: AppTypography.titleMedium.copyWith(color: foreground),
              cursorColor: foreground,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: hintText,
                hintStyle: AppTypography.titleMedium.copyWith(
                  color: secondary,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _ShortcutChip(label: 'Esc', isDark: isDark),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: closeTooltip,
            icon: const Icon(Icons.close_rounded, size: 20),
            color: secondary,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: text.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: text.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Body region — sections + result items (or skeleton / empty state).
class _PaletteBody extends ConsumerWidget {
  const _PaletteBody({
    required this.state,
    required this.isDark,
    required this.highlight,
    required this.onHighlightChanged,
    required this.scrollController,
    required this.onActivate,
  });

  final CommandPaletteState state;
  final bool isDark;
  final int highlight;
  final ValueChanged<int> onHighlightChanged;
  final ScrollController scrollController;
  final ValueChanged<CommandPaletteResult> onActivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hasAnySectionEntry = state.pages.isNotEmpty ||
        state.recipes.isNotEmpty ||
        state.pantry.isNotEmpty ||
        state.recipesPending ||
        state.pantryPending;

    if (!hasAnySectionEntry) {
      return _EmptyState(
        title: l10n.cmdPaletteEmptyTitle,
        subtitle: state.query.trim().isEmpty
            ? l10n.cmdPaletteSearchHint
            : l10n.cmdPaletteEmptyFor(state.query),
        hint: l10n.cmdPaletteEmptyHint,
        isDark: isDark,
        query: state.query,
      );
    }

    final sections = <Widget>[];
    var runningIndex = 0;

    if (state.pages.isNotEmpty) {
      sections.add(_SectionHeader(
        label: l10n.cmdPalettePages,
        isDark: isDark,
      ));
      for (var i = 0; i < state.pages.length; i++) {
        final result = state.pages[i];
        final globalIndex = runningIndex + i;
        sections.add(CommandPaletteResultItem(
          label: result.label,
          subtitle: result.subtitle,
          icon: result.icon,
          iconColor: result.iconColor,
          category: CommandPaletteResultItemCategoryX.categoryLabelFor(
            context,
            result.category,
          ),
          onTap: () => onActivate(result),
          highlighted: globalIndex == highlight,
        ));
      }
      runningIndex += state.pages.length;
    }

    if (state.recipes.isNotEmpty || state.recipesPending) {
      sections.add(_SectionHeader(
        label: l10n.cmdPaletteRecipes,
        isDark: isDark,
      ));
      if (state.recipesPending && state.recipes.isEmpty) {
        for (var i = 0; i < 3; i++) {
          sections.add(const _SkeletonRow());
        }
      } else {
        for (var i = 0; i < state.recipes.length; i++) {
          final result = state.recipes[i];
          final globalIndex = runningIndex + i;
          sections.add(CommandPaletteResultItem(
            label: result.label,
            subtitle: result.subtitle,
            icon: result.icon,
            iconColor: result.iconColor,
            category: CommandPaletteResultItemCategoryX.categoryLabelFor(
              context,
              result.category,
            ),
            onTap: () => onActivate(result),
            highlighted: globalIndex == highlight,
          ));
        }
      }
      runningIndex += state.recipes.length;
    }

    if (state.pantry.isNotEmpty || state.pantryPending) {
      sections.add(_SectionHeader(
        label: l10n.cmdPalettePantry,
        isDark: isDark,
      ));
      if (state.pantryPending && state.pantry.isEmpty) {
        for (var i = 0; i < 3; i++) {
          sections.add(const _SkeletonRow());
        }
      } else {
        for (var i = 0; i < state.pantry.length; i++) {
          final result = state.pantry[i];
          final globalIndex = runningIndex + i;
          sections.add(CommandPaletteResultItem(
            label: result.label,
            subtitle: result.subtitle,
            icon: result.icon,
            iconColor: result.iconColor,
            category: CommandPaletteResultItemCategoryX.categoryLabelFor(
              context,
              result.category,
            ),
            onTap: () => onActivate(result),
            highlighted: globalIndex == highlight,
          ));
        }
      }
      runningIndex += state.pantry.length;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 480),
      child: ListView(
        controller: scrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        children: sections,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tint =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: const [
          PpSkeleton(width: 36, height: 36),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PpSkeleton(height: 14, width: double.infinity),
                SizedBox(height: 6),
                PpSkeleton(height: 10, width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.isDark,
    required this.query,
  });

  final String title;
  final String subtitle;
  final String hint;
  final bool isDark;
  final String query;

  @override
  Widget build(BuildContext context) {
    final tint =
        isDark ? AppColors.darkOnSurfaceTertiary : AppColors.onSurfaceTertiary;
    final body =
        isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 480),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 36, color: tint),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: body),
            ),
            if (hint.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(color: tint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
