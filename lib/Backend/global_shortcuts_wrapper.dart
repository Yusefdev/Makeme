import 'package:flutter/material.dart';

typedef ShortcutCallback = void Function(LogicalKeySet keys);

class GlobalShortcutHandler extends StatefulWidget {
  final Widget child;
  final LogicalKeySet triggerKeys;

  const GlobalShortcutHandler({
    super.key,
    required this.child,
    required this.triggerKeys,
  });

  static _GlobalShortcutHandlerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_GlobalShortcutHandlerState>();
  }

  @override
  State<GlobalShortcutHandler> createState() => _GlobalShortcutHandlerState();
}

class _GlobalShortcutHandlerState extends State<GlobalShortcutHandler> {
  ShortcutCallback? _onShortcut;

  void registerShortcutCallback(ShortcutCallback callback) {
    _onShortcut = callback;
  }

  void clearCallback() {
    _onShortcut = null;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        widget.triggerKeys: const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _onShortcut?.call(widget.triggerKeys);
              return null;
            },
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}