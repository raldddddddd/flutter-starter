import 'package:flutter/material.dart';

import '../../core/design/app_layout_tokens.dart';
import '../../core/design/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
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
            final l10n = AppLocalizations.of(context);
            final spacing = context.layout;
            final scheme = Theme.of(context).colorScheme;
            final type = Theme.of(context).textTheme;
            return Scaffold(
              appBar: AppBar(title: Text(l10n.componentShowcaseTitle)),
              body: SafeArea(
                child: ListView(
                  padding: EdgeInsets.all(spacing.spaceMd),
                  children: [
                    SwitchListTile(
                      title: Text(l10n.showcaseDarkTheme),
                      value: _dark,
                      onChanged: (value) => setState(() => _dark = value),
                    ),
                    SwitchListTile(
                      title: Text(l10n.showcaseLargeText),
                      value: _largeText,
                      onChanged: (value) => setState(() => _largeText = value),
                    ),
                    _Section(
                      title: l10n.showcaseSemanticColors,
                      child: Wrap(
                        spacing: spacing.spaceSm,
                        runSpacing: spacing.spaceSm,
                        children: [
                          _ColorSample(
                            l10n.showcasePrimaryColor,
                            scheme.primary,
                            scheme.onPrimary,
                          ),
                          _ColorSample(
                            l10n.showcaseSecondaryColor,
                            scheme.secondary,
                            scheme.onSecondary,
                          ),
                          _ColorSample(
                            l10n.showcaseSurfaceColor,
                            scheme.surface,
                            scheme.onSurface,
                          ),
                          _ColorSample(
                            l10n.showcaseErrorColor,
                            scheme.error,
                            scheme.onError,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: l10n.showcaseTypography,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.showcaseDisplaySmall,
                            style: type.displaySmall,
                          ),
                          Text(l10n.showcaseTitleLarge, style: type.titleLarge),
                          Text(l10n.showcaseBodyLarge, style: type.bodyLarge),
                          Text(l10n.showcaseLabelLarge, style: type.labelLarge),
                        ],
                      ),
                    ),
                    _Section(
                      title: l10n.showcaseSpacingRadius,
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
                      title: l10n.showcaseButtons,
                      child: Wrap(
                        spacing: spacing.spaceSm,
                        runSpacing: spacing.spaceSm,
                        children: [
                          PrimaryButton(
                            label: l10n.showcasePrimaryButton,
                            onPressed: () {},
                          ),
                          SecondaryButton(
                            label: l10n.showcaseSecondaryButton,
                            onPressed: () {},
                          ),
                          AppTextButton(
                            label: l10n.showcaseTextButton,
                            onPressed: () {},
                          ),
                          PrimaryButton(
                            label: l10n.showcaseDisabledButton,
                            onPressed: null,
                          ),
                          PrimaryButton(
                            label: l10n.showcaseLoadingButton,
                            onPressed: () {},
                            isLoading: true,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: l10n.showcaseTextInput,
                      child: Column(
                        children: [
                          AppTextInput(
                            label: l10n.showcaseName,
                            hint: l10n.showcaseNameHint,
                          ),
                          SizedBox(height: spacing.spaceMd),
                          AppTextInput(
                            label: l10n.showcaseDisabledInput,
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: l10n.showcaseCardLongCopy,
                      child: Text(l10n.showcaseLongCopy),
                    ),
                    _Section(
                      title: l10n.showcaseLoadingState,
                      child: LoadingState(label: l10n.showcaseLoadingContent),
                    ),
                    _Section(
                      title: l10n.showcaseEmptyState,
                      child: EmptyState(
                        title: l10n.showcaseNothingHere,
                        message: l10n.showcaseNewContent,
                      ),
                    ),
                    _Section(
                      title: l10n.showcaseErrorState,
                      child: ErrorState(
                        title: l10n.showcaseCouldNotLoad,
                        message: l10n.showcaseCheckConnection,
                        onRetry: () {},
                      ),
                    ),
                    _Section(
                      title: l10n.showcaseFormatting,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.showcaseGreeting('Developer')),
                          Text(l10n.sampleItemCount(2)),
                          Text(l10n.showcaseDate(DateTime(2026, 9, 26))),
                          Text(
                            l10n.showcaseTime(DateTime(2026, 9, 26, 14, 30)),
                          ),
                          Text(l10n.showcaseNumber(12345.67)),
                          Text(l10n.showcaseCurrency(1234.5)),
                        ],
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
