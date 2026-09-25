import 'package:flutter/material.dart';

import '../../core/design/app_layout_tokens.dart';
import 'app_buttons.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({this.label = 'Loading', super.key});

  final String label;

  @override
  Widget build(BuildContext context) => _StateContent(
    icon: const CircularProgressIndicator(),
    title: label,
    liveRegion: true,
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, this.message, super.key});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) => _StateContent(
    icon: const Icon(Icons.inbox_outlined, size: 32, semanticLabel: 'Empty'),
    title: title,
    message: message,
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    required this.message,
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _StateContent(
    icon: Icon(
      Icons.error_outline,
      size: 32,
      color: Theme.of(context).colorScheme.error,
      semanticLabel: 'Error',
    ),
    title: title,
    message: message,
    liveRegion: true,
    action: onRetry == null
        ? null
        : SecondaryButton(label: 'Retry', onPressed: onRetry),
  );
}

class _StateContent extends StatelessWidget {
  const _StateContent({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.liveRegion = false,
  });

  final Widget icon;
  final String title;
  final String? message;
  final Widget? action;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final spacing = context.layout;
    return Semantics(
      liveRegion: liveRegion,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.spaceMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: spacing.spaceSm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message case final value?) ...[
                SizedBox(height: spacing.spaceXs),
                Text(value, textAlign: TextAlign.center),
              ],
              if (action case final value?) ...[
                SizedBox(height: spacing.spaceMd),
                value,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
