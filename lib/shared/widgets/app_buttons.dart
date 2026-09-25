import 'package:flutter/material.dart';

import '../../core/design/app_layout_tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: isLoading ? null : onPressed,
    child: _ButtonContent(label: label, isLoading: isLoading),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: isLoading ? null : onPressed,
    child: _ButtonContent(label: label, isLoading: isLoading),
  );
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: isLoading ? null : onPressed,
    child: _ButtonContent(label: label, isLoading: isLoading),
  );
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.isLoading});

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return Text(label, textAlign: TextAlign.center);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            semanticsLabel: 'Loading',
          ),
        ),
        SizedBox(width: context.layout.spaceSm),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}
