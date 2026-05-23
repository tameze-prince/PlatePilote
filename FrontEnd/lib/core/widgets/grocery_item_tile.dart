import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../shared/models/grocery_list.dart';
import 'app_card.dart';

class GroceryItemTile extends StatefulWidget {
  const GroceryItemTile({
    required this.item,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final GroceryItem item;
  final void Function()? onToggle;
  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  State<GroceryItemTile> createState() => _GroceryItemTileState();
}

class _GroceryItemTileState extends State<GroceryItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragStartX = 0;
  bool _isOpen = false;

  static const double _actionWidth = 60;
  static const double _totalActions = 2;
  static const double _revealWidth = _actionWidth * _totalActions;
  static const double _dragThreshold = 30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-(_revealWidth / MediaQuery.of(context).size.width), 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    if (!_isOpen) {
      _isOpen = true;
      _controller.forward();
    }
  }

  void _close() {
    if (_isOpen) {
      _isOpen = false;
      _controller.reverse();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isOpen && details.localPosition.dx < _dragStartX - _dragThreshold) {
      _open();
    }
  }

  void _onTap() {
    if (_isOpen) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final qty = widget.item.quantity != null
        ? '${widget.item.quantity} ${widget.item.unit ?? ''}'.trim()
        : '';
    final price = widget.item.estimatedPrice != null
        ? '\$${widget.item.estimatedPrice!.toStringAsFixed(2)}'
        : '';
    final hasActions = widget.onEdit != null || widget.onDelete != null;

    final tileContent = Row(
      children: [
        Checkbox(
          value: widget.item.checked,
          onChanged: (_) {
            if (_isOpen) _close();
            widget.onToggle?.call();
          },
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.name,
                style: context.text.bodyLarge?.copyWith(
                  decoration: widget.item.checked
                      ? TextDecoration.lineThrough
                      : null,
                  color: widget.item.checked
                      ? context.text.bodyMedium?.color
                      : null,
                ),
              ),
              if (qty.isNotEmpty)
                Text(
                  'Qty: $qty',
                  style: context.text.bodyMedium?.copyWith(
                    decoration: widget.item.checked
                        ? TextDecoration.lineThrough
                        : null,
                    color: widget.item.checked
                        ? context.text.bodyMedium?.color
                        : null,
                  ),
                ),
            ],
          ),
        ),
        if (price.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(
              price,
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );

    if (!hasActions) {
      return AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: tileContent,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _onTap,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onEdit != null)
                    _actionButton(
                      icon: Icons.edit_outlined,
                      label: 'Qty',
                      color: AppColors.info,
                      onTap: () {
                        _close();
                        widget.onEdit?.call();
                      },
                    ),
                  if (widget.onDelete != null)
                    _actionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: AppColors.error,
                      onTap: () {
                        _close();
                        widget.onDelete?.call();
                      },
                    ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _slideAnimation.value.dx * screenWidth,
                  0,
                ),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: tileContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _actionWidth,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


