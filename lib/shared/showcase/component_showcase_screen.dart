import 'package:flutter/material.dart';

import '../../core/design/app_layout_tokens.dart';
import '../../core/design/app_theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_card.dart';
import '../widgets/app_states.dart';
import '../widgets/app_text_input.dart';

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  bool _dark = false;
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Theme(
      data: _dark ? AppTheme.dark : AppTheme.light,
      child: MediaQuery(
        data: media.copyWith(
          textScaler: _largeText
              ? const TextScaler.linear(1.8)
              : media.textScaler,
        ),
        child: Builder(
          builder: (context) {
            final spacing = context.layout;
            final scheme = Theme.of(context).colorScheme;
            final type = Theme.of(context).textTheme;
            return Scaffold(
              appBar: AppBar(title: const Text('Component Showcase')),
              body: SafeArea(
                child: ListView(
                  padding: EdgeInsets.all(spacing.spaceMd),
                  children: [
                    SwitchListTile(
                      title: const Text('Dark theme'),
                      value: _dark,
                      onChanged: (value) => setState(() => _dark = value),
                    ),
                    SwitchListTile(
                      title: const Text('Large text (180%)'),
                      value: _largeText,
                      onChanged: (value) => setState(() => _largeText = value),
                    ),
                    _Section(
                      title: 'Semantic colors',
                      child: Wrap(
                        spacing: spacing.spaceSm,
                        runSpacing: spacing.spaceSm,
                        children: [
                          _ColorSample(
                            'Primary',
                            scheme.primary,
                            scheme.onPrimary,
                          ),
                          _ColorSample(
                            'Secondary',
                            scheme.secondary,
                            scheme.onSecondary,
                          ),
                          _ColorSample(
                            'Surface',
                            scheme.surface,
                            scheme.onSurface,
                          ),
                          _ColorSample('Error', scheme.error, scheme.onError),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Typography',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Display small', style: type.displaySmall),
                          Text('Title large', style: type.titleLarge),
                          Text('Body large', style: type.bodyLarge),
                          Text('Label large', style: type.labelLarge),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Spacing and radius',
                      child: Wrap(
                        spacing: spacing.spaceMd,
                        runSpacing: spacing.spaceMd,
                        children: [
                          _TokenSample(
                            'XS 4',
                            spacing.spaceXs,
                            spacing.radiusSm,
                          ),
                          _TokenSample(
                            'SM 8',
                            spacing.spaceSm,
                            spacing.radiusSm,
                          ),
                          _TokenSample(
                            'MD 16',
                            spacing.spaceMd,
                            spacing.radiusMd,
                          ),
                          _TokenSample(
                            'LG 24',
                            spacing.spaceLg,
                            spacing.radiusMd,
                          ),
                          _TokenSample(
                            'XL 32',
                            spacing.spaceXl,
                            spacing.radiusMd,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Buttons',
                      child: Wrap(
                        spacing: spacing.spaceSm,
                        runSpacing: spacing.spaceSm,
                        children: [
                          PrimaryButton(label: 'Primary', onPressed: () {}),
                          SecondaryButton(label: 'Secondary', onPressed: () {}),
                          AppTextButton(label: 'Text', onPressed: () {}),
                          const PrimaryButton(
                            label: 'Disabled',
                            onPressed: null,
                          ),
                          PrimaryButton(
                            label: 'Loading',
                            onPressed: () {},
                            isLoading: true,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Text input',
                      child: Column(
                        children: [
                          const AppTextInput(
                            label: 'Name',
                            hint: 'Enter a name',
                          ),
                          SizedBox(height: spacing.spaceMd),
                          const AppTextInput(
                            label: 'Disabled input',
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                    const _Section(
                      title: 'Card and long copy',
                      child: Text(
                        'This is intentionally long copy. It demonstrates how '
                        'the starter card and typography respond when content '
                        'wraps across several lines, the screen is narrow, or '
                        'the reader chooses a much larger text size.',
                      ),
                    ),
                    const _Section(
                      title: 'Loading state',
                      child: LoadingState(label: 'Loading content'),
                    ),
                    const _Section(
                      title: 'Empty state',
                      child: EmptyState(
                        title: 'Nothing here yet',
                        message: 'New content will appear here when available.',
                      ),
                    ),
                    _Section(
                      title: 'Error state',
                      child: ErrorState(
                        title: 'Could not load content',
                        message: 'Check your connection and try again.',
                        onRetry: () {},
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.layout;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.spaceSm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: spacing.spaceMd),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorSample extends StatelessWidget {
  const _ColorSample(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 112, minHeight: 64),
    alignment: Alignment.center,
    padding: EdgeInsets.all(context.layout.spaceSm),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(context.layout.radiusSm),
    ),
    child: Text(label, style: TextStyle(color: foreground)),
  );
}

class _TokenSample extends StatelessWidget {
  const _TokenSample(this.label, this.space, this.radius);

  final String label;
  final double space;
  final double radius;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 56,
        height: 56,
        padding: EdgeInsets.all(space),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ColoredBox(color: Theme.of(context).colorScheme.primary),
      ),
      SizedBox(height: context.layout.spaceXs),
      Text(label),
    ],
  );
}
