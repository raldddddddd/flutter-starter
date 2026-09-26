import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../../app/developer_flags.dart';
import '../../features/sample/presentation/sample_demo_entry.dart';
import '../../features/sample/presentation/sample_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/showcase/component_showcase_screen.dart';
import '../../shared/widgets/app_buttons.dart';
import 'app_gate.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(l10n.appTitle)),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.environmentLabel(config.environment.name)),
                      AppTextButton(
                        label: l10n.sampleItemsTitle,
                        onPressed: () => context.go('/sample'),
                      ),
                      if (kEnableComponentShowcase &&
                          config.environment != AppEnvironment.prod)
                        AppTextButton(
                          label: l10n.componentShowcaseTitle,
                          onPressed: () => context.go('/showcase'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/bootstrap',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/update-required',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.updateRequiredTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.updateRequiredMessage,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => config.environment == AppEnvironment.dev
            ? const SampleDemoEntry()
            : Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).signInNotConfigured,
                    ),
                  ),
                ),
              ),
      ),
      GoRoute(
        path: '/sample',
        builder: (context, state) => const SampleScreen(),
      ),
      if (kEnableComponentShowcase && config.environment != AppEnvironment.prod)
        GoRoute(
          path: '/showcase',
          builder: (context, state) => const ComponentShowcaseScreen(),
        ),
    ],
    redirect: (context, state) {
      final gate = ref.read(appGateProvider);
      final location = state.matchedLocation;
      if (gate == AppGateState.bootstrapping) {
        return location == '/bootstrap' ? null : '/bootstrap';
      }
      if (gate == AppGateState.updateRequired) {
        return location == '/update-required' ? null : '/update-required';
      }
      if (gate == AppGateState.unauthenticated) {
        return location == '/login' ? null : '/login';
      }
      if (location == '/bootstrap' ||
          location == '/login' ||
          location == '/update-required') {
        return '/';
      }
      return null;
    },
  );
  ref.listen(appGateProvider, (previous, next) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
}
