import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/design/app_layout_tokens.dart';
import 'package:flutter_starter/core/design/app_theme.dart';
import 'package:flutter_starter/l10n/generated/app_localizations.dart';
import 'package:flutter_starter/shared/showcase/component_showcase_screen.dart';
import 'package:flutter_starter/shared/widgets/app_buttons.dart';
import 'package:flutter_starter/shared/widgets/app_card.dart';
import 'package:flutter_starter/shared/widgets/app_states.dart';
import 'package:flutter_starter/shared/widgets/app_text_input.dart';

void main() {
  test('semantic color pairs meet text contrast baseline in both themes', () {
    double contrast(Color a, Color b) {
      final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
      final darker = identical(lighter, a) ? b : a;
      return (lighter.computeLuminance() + 0.05) /
          (darker.computeLuminance() + 0.05);
    }

    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final colors = theme.colorScheme;
      for (final (foreground, background) in [
        (colors.onPrimary, colors.primary),
        (colors.onSecondary, colors.secondary),
        (colors.onSurface, colors.surface),
        (colors.onError, colors.error),
      ]) {
        expect(contrast(foreground, background), greaterThanOrEqualTo(4.5));
      }
    }
  });

  testWidgets('light and dark themes expose semantic color and layout roles', (
    tester,
  ) async {
    for (final (mode, brightness) in [
      (ThemeMode.light, Brightness.light),
      (ThemeMode.dark, Brightness.dark),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: Builder(
            builder: (context) => Scaffold(
              body: Text(
                Theme.of(context).colorScheme.brightness.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(brightness.name), findsOneWidget);
      final context = tester.element(find.byType(Scaffold));
      expect(context.layout.spaceMd, 16);
      expect(context.layout.radiusMd, 16);
      expect(Theme.of(context).textTheme.titleLarge, isNotNull);
    }
  });

  testWidgets('buttons expose enabled, disabled and loading behavior', (
    tester,
  ) async {
    var presses = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              PrimaryButton(label: 'Save', onPressed: () => presses++),
              const SecondaryButton(label: 'Unavailable', onPressed: null),
              AppTextButton(
                label: 'Working',
                onPressed: () => presses++,
                isLoading: true,
              ),
            ],
          ),
        ),
      ),
    );

    final primary = tester
        .getSemantics(find.byType(FilledButton))
        .getSemanticsData();
    expect(primary.flagsCollection.isButton, isTrue);
    expect(primary.hasAction(SemanticsAction.tap), isTrue);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byType(TextButton)).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.text('Save'));
    expect(presses, 1);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .semanticsLabel,
      'Loading',
    );
    semantics.dispose();
  });

  testWidgets('input, card and states stay readable at large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AppCard(
                    child: Text(
                      'A long sentence that must wrap at large text sizes.',
                    ),
                  ),
                  const AppTextInput(label: 'Name'),
                  const AppTextInput(label: 'Disabled name', enabled: false),
                  const LoadingState(label: 'Loading content'),
                  const EmptyState(title: 'Nothing here', message: 'Try later'),
                  ErrorState(
                    title: 'Could not load',
                    message: 'Please try again',
                    onRetry: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Name'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).enabled,
      isFalse,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.inbox_outlined)).semanticLabel,
      'Empty',
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.error_outline)).semanticLabel,
      'Error',
    );
    await tester.ensureVisible(find.text('Could not load'));
    await tester.pump();
    expect(find.text('Could not load'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('showcase switches theme and survives large text on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ComponentShowcaseScreen(),
      ),
    );
    expect(find.text('Semantic colors'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Semantic colors'))).brightness,
      Brightness.light,
    );
    await tester.tap(find.text('Dark theme'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      Theme.of(tester.element(find.text('Semantic colors'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Large text (180%)'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(
      find.text('Error state'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('showcase respects insets and long copy at 250% text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 42, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 42, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.5)),
          child: child!,
        ),
        home: const ComponentShowcaseScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(find.byType(ListView)).dy,
      lessThanOrEqualTo(810),
    );
    await tester.scrollUntilVisible(
      find.textContaining('This is intentionally long copy'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Localized formatting'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.textContaining('Number: 12,345.67'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long error content remains scrollable in a short viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3)),
            child: SizedBox(
              width: 320,
              height: 180,
              child: ErrorState(
                title: 'A longer translated error heading that wraps',
                message:
                    'A longer translated explanation that needs several lines.',
                onRetry: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.ensureVisible(find.text('Retry'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
