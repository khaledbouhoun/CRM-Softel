import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/l10n/l10n.dart';

/// Asks for confirmation before an important action. Returns true when the
/// user confirmed.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await Get.dialog<bool>(
    Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(cancelLabel ?? tr.actionCancel),
            ),
            FilledButton(
              autofocus: true,
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: () => Get.back(result: true),
              child: Text(confirmLabel ?? tr.actionConfirm),
            ),
          ],
        );
      },
    ),
  );
  return result ?? false;
}

/// Opens a dialog bound to its own controller instance and disposes the
/// controller only when the dialog widget is completely unmounted from the
/// widget tree (preventing controllers from being disposed during the dialog
/// pop animation while widgets are still listening to them).
Future<T?> showControllerDialog<C extends GetxController, T>({
  required C controller,
  required Widget Function(C controller) builder,
  bool barrierDismissible = false,
}) async {
  final tag = 'dialog-${identityHashCode(controller)}';
  Get.put<C>(controller, tag: tag);
  var isMounted = false;
  try {
    return await Get.dialog<T>(
      _ControllerDialogScope<C>(
        tag: tag,
        onMounted: () => isMounted = true,
        child: builder(controller),
      ),
      barrierDismissible: barrierDismissible,
    );
  } finally {
    // If the dialog was never mounted (e.g. an exception was thrown before
    // the route was pushed), clean up the controller immediately.
    if (!isMounted && Get.isRegistered<C>(tag: tag)) {
      Get.delete<C>(tag: tag, force: true);
    }
  }
}

class _ControllerDialogScope<C extends GetxController> extends StatefulWidget {
  const _ControllerDialogScope({
    super.key,
    required this.tag,
    required this.child,
    this.onMounted,
  });

  final String tag;
  final Widget child;
  final VoidCallback? onMounted;

  @override
  State<_ControllerDialogScope<C>> createState() =>
      _ControllerDialogScopeState<C>();
}

class _ControllerDialogScopeState<C extends GetxController>
    extends State<_ControllerDialogScope<C>> {
  @override
  void initState() {
    super.initState();
    widget.onMounted?.call();
  }

  @override
  void dispose() {
    if (Get.isRegistered<C>(tag: widget.tag)) {
      Get.delete<C>(tag: widget.tag, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
