import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../state/load_state.dart';
import '../../app/l10n/l10n.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: context.text.bodyMedium),
          ],
        ],
      ),
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 28 : 44,
              color: muted.withValues(alpha: 0.6),
            ),
            SizedBox(height: compact ? 6 : 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  (compact ? context.text.bodyMedium : context.text.titleMedium)
                      ?.copyWith(color: muted),
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: muted),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.isConnectionError = false,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool isConnectionError;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnectionError
                    ? Icons.cloud_off_outlined
                    : Icons.error_outline,
                size: compact ? 28 : 44,
                color: crm.danger,
              ),
              const SizedBox(height: 10),
              Text(
                isConnectionError ? tr.serverUnreachable : tr.errorOccurred,
                style: context.text.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (onRetry != null)
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(tr.actionRetry),
                    ),
                  if (isConnectionError)
                    OutlinedButton.icon(
                      onPressed: () => Get.offAllNamed(Routes.settings),
                      icon: const Icon(Icons.settings_ethernet, size: 18),
                      label: Text(tr.serverSettings),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chooses between loading / error / empty / content for a [LoadState].
/// Rebuilds by itself when the state changes; [isEmpty] must come from an
/// enclosing `Obx` when it depends on observables.
class LoadStateView extends StatelessWidget {
  const LoadStateView({
    super.key,
    required this.state,
    required this.isEmpty,
    required this.builder,
    this.onRetry,
    this.empty,
    this.compact = false,
  });

  final LoadState state;
  final bool isEmpty;
  final WidgetBuilder builder;
  final VoidCallback? onRetry;
  final Widget? empty;
  final bool compact;

  @override
  Widget build(BuildContext context) => Obx(() => _build(context));

  Widget _build(BuildContext context) {
    final status = state.status.value;
    if (status == LoadStatus.error && isEmpty) {
      return ErrorView(
        message: state.errorMessage.value ?? tr.errorUnknown,
        onRetry: onRetry,
        isConnectionError: state.isConnectionError,
        compact: compact,
      );
    }
    if ((status == LoadStatus.loading || status == LoadStatus.initial) &&
        isEmpty) {
      return const LoadingView();
    }
    if (isEmpty) {
      return empty ?? EmptyView(title: tr.noItems);
    }
    return builder(context);
  }
}

/// Thin progress bar shown on top of content while refreshing.
class RefreshingBar extends StatelessWidget {
  const RefreshingBar({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 2,
    child: visible ? const LinearProgressIndicator(minHeight: 2) : null,
  );
}

/// Inline error banner (forms, dialogs, stale data).
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final crm = context.crm;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: crm.dangerContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: crm.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: crm.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: context.text.bodyMedium)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(tr.actionRetry)),
        ],
      ),
    );
  }
}
