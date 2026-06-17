import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';

/// Public entry point for the in-app command palette inspired by
/// Linear / Notion / Vercel cmd-K.
///
/// Use:
///
/// ```dart
/// PpCommandPalette.show(context);            // mobile / modal
/// PpCommandPalette.show(context, push: true) // push as full route
/// ```
///
/// A shortcut listener is also exposed via [PpCommandPalette.shortcuts]
/// so screens can wire Cmd+K / Ctrl+K globally without duplicating the
/// Focus + KeyEvent plumbing.
class PpCommandPalette {
  PpCommandPalette._();

  /// Open the palette via a named route push.
  ///
  /// Returns the [Future] of the pushed route so callers can `await` the
  /// user dismissing the modal if needed.
  static Future<T?> show<T>(
    BuildContext context, {
    bool push = false,
  }) {
    if (push) {
      return context.push<T>(AppRoute.commandPalette.name);
    }
    return context.pushNamed<T>(
      AppRoute.commandPalette.name,
      pathParameters: const {},
    );
  }
}

/// A focus widget that binds `Cmd+K` / `Ctrl+K` to open the palette.
///
/// Wrap a screen `body` with [PpCommandPalette.shortcuts] to enable a
/// keyboard shortcut even outside the modal itself.
class CommandPaletteShortcuts extends StatelessWidget {
  const CommandPaletteShortcuts({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const _OpenCommandPaletteIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            const _OpenCommandPaletteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenCommandPaletteIntent: CallbackAction<_OpenCommandPaletteIntent>(
            onInvoke: (_) {
              PpCommandPalette.show<void>(context);
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _OpenCommandPaletteIntent extends Intent {
  const _OpenCommandPaletteIntent();
}
