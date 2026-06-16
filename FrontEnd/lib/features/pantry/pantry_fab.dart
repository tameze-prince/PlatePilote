import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';

/// Provider global d'état du menu FAB du Pantry.
/// Plusieurs widgets partagent cet état — le FAB principal ET l'overlay plein écran.
final pantryMenuOpenProvider = StateProvider<bool>((ref) => false);

/// Rotation du + — le bouton principal pivote à 45° (= ✕) pour fermer le menu.
class PantryFab extends ConsumerStatefulWidget {
  const PantryFab({super.key});

  @override
  ConsumerState<PantryFab> createState() => _PantryFabState();
}

class _PantryFabState extends ConsumerState<PantryFab>
    with SingleTickerProviderStateMixin {
  // Couleurs PlatePilote
  static const _green = AppColors.primaryAccentGreen; // #22C55E
  static const _greenDark = AppColors.deepGreen; // #16A34A

  late final AnimationController _controller;
  late final Animation<double> _rotateAnim;

  late final List<_FabAction> _actions = [
    _FabAction(
      icon: Icons.search_rounded,
      label: 'Rechercher',
      onTap: () => _go('/search'),
    ),
    _FabAction(
      icon: Icons.edit_note_rounded,
      label: 'Ajout manuel',
      onTap: () => _go('/pantry/add'),
    ),
    _FabAction(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan code-barres',
      onTap: () => _go('/pantry/add?scan=true'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final isOpen = ref.read(pantryMenuOpenProvider.notifier).state;
    ref.read(pantryMenuOpenProvider.notifier).state = !isOpen;
  }

  void _go(String route) {
    ref.read(pantryMenuOpenProvider.notifier).state = false;
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    // Synchroniser l'animation avec l'état du provider
    ref.listen<bool>(pantryMenuOpenProvider, (prev, next) {
      if (next) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    final isOpen = ref.watch(pantryMenuOpenProvider);

    return SizedBox(
      // Hauteur suffisante pour empiler 3 actions au-dessus du bouton principal
      width: 280.0,
      height: 64.0 + 70.0 * _actions.length, // bouton + 3×70px par ligne
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          // ── Actions secondaires (du bas vers le haut, stagger) ──
          ..._actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            final delayedAnim = CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.08,
                0.5 + index * 0.10,
                curve: Curves.easeOutCubic,
              ),
            );
            return AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Positioned(
                  right: 6,
                  bottom: 70 + index * 70.0, // 70px (FAB) + 70 par action
                  child: Opacity(
                    opacity: delayedAnim.value,
                    child: IgnorePointer(
                      ignoring: !isOpen,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(delayedAnim),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: _FabRow(
                action: action,
                color: _green,
                colorDark: _greenDark,
              ),
            );
          }),

          // ── Bouton principal (+) ──
          Positioned(
            right: 6,
            bottom: 10,
            child: AnimatedBuilder(
              animation: _rotateAnim,
              builder: (_, child) =>
                  RotationTransition(turns: _rotateAnim, child: child),
              child: FloatingActionButton(
                onPressed: _toggle,
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 6,
                tooltip: isOpen ? 'Fermer' : 'Ajouter un ingrédient',
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay plein-écran — affiche un voile sombre cliquable quand le menu
/// est ouvert. À placer **autour** du contenu scrollable de la page (au-
/// dessus du body, sous le FAB).
class PantryMenuOverlay extends ConsumerWidget {
  const PantryMenuOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // L'overlay a sa propre animation interne pour FadeIn/Out
    final isOpen = ref.watch(pantryMenuOpenProvider);
    return Stack(
      children: [
        child,
        if (isOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ref.read(pantryMenuOpenProvider.notifier).state = false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                color: Colors.black.withValues(alpha: 0.20),
              ),
            ),
          ),
      ],
    );
  }
}

/// Modèle d'une action FAB.
class _FabAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Ligne : pastille label à gauche + bouton rond à droite (44x44).
class _FabRow extends StatefulWidget {
  final _FabAction action;
  final Color color;
  final Color colorDark;

  const _FabRow({
    required this.action,
    required this.color,
    required this.colorDark,
  });

  @override
  State<_FabRow> createState() => _FabRowState();
}

class _FabRowState extends State<_FabRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Pastille label (blanc + bordure légère) ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.action.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Bouton rond 44x44 (Material/HIG guideline) ──
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.action.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _pressed ? widget.colorDark : widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.40),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(widget.action.icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
