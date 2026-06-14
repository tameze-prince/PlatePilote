import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// FAB personnalisé pour l'écran Pantry.
///
/// Reproduit le design CustomFAB (overlay + 3 actions révélées par stagger),
/// mais stylisé avec les couleurs PlatePilote (vert primaryAccentGreen / deepGreen)
/// et routing GoRouter vers :
///   - /search (recherche d'ingrédients)
///   - /pantry/add (ajout manuel)
///   - /pantry/add?scan=true (scan/codebar — affiché en mode formulaire
///     avec un bouton scan capturé par l'écran d'ajout)
class PantryFab extends StatefulWidget {
  const PantryFab({super.key});

  @override
  State<PantryFab> createState() => _PantryFabState();
}

class _PantryFabState extends State<PantryFab>
    with SingleTickerProviderStateMixin {
  /// Couleur principale PlatePilote (vert accent).
  static const _greenLight = AppColors.primaryAccentGreen; // 0xFF22C55E
  static const _greenDark = AppColors.deepGreen; // 0xFF16A34A

  bool _isOpen = false;

  late final AnimationController _controller;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _overlayAnim;

  late final List<_FabAction> _actions = [
    _FabAction(
      icon: Icons.search_rounded,
      label: 'Rechercher',
      onTap: () {
        _toggle();
        context.push('/search');
      },
    ),
    _FabAction(
      icon: Icons.edit_outlined,
      label: 'Ajout manuel',
      onTap: () {
        _toggle();
        context.push('/pantry/add');
      },
    ),
    _FabAction(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan code-barres',
      onTap: () {
        _toggle();
        context.push('/pantry/add?scan=true');
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.125) // 45°
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _overlayAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // ── Overlay teinté ──
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: FadeTransition(
                opacity: _overlayAnim,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.20),
                ),
              ),
            ),
          ),

        // ── Colonne actions + bouton principal ──
        Padding(
          // Marge basse pour ne pas couvrir la BottomNav si présente
          padding: const EdgeInsets.only(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Actions secondaires (Recherche, Ajout, Scan)
              ..._actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                final delayedAnim = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    index * 0.08,
                    0.6 + index * 0.08,
                    curve: Curves.easeOutCubic,
                  ),
                );
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    return FadeTransition(
                      opacity: delayedAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(delayedAnim),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FabRow(
                      action: action,
                      color: _greenLight,
                      colorDark: _greenDark,
                    ),
                  ),
                );
              }),

              // ── Bouton principal (+) ──
              GestureDetector(
                onTap: _toggle,
                child: AnimatedBuilder(
                  animation: _rotateAnim,
                  builder: (_, child) => RotationTransition(
                    turns: _rotateAnim,
                    child: child,
                  ),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_greenLight, _greenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _greenLight.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Modèle interne — chaque action révélée par le FAB.
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

/// Ligne : pastille label + pastille bouton (avec micro-interaction scale).
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
        // ── Pastille label ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
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

        // ── Bouton rond ──
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
              width: 50,
              height: 50,
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
              child: Icon(
                widget.action.icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
