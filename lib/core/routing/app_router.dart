import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/app_config.dart';
import '../../app/developer_flags.dart';
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
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Flutter Starter')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Environment: ${config.environment.name}'),
                if (kEnableComponentShowcase &&
                    config.environment != AppEnvironment.prod)
                  AppTextButton(
                    label: 'Component Showcase',
                    onPressed: () => context.go('/showcase'),
                  ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/bootstrap',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Sign in is not configured yet.')),
        ),
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
      if (gate == AppGateState.unauthenticated) {
        return location == '/login' ? null : '/login';
      }
      if (location == '/bootstrap' || location == '/login') return '/';
      return null;
    },
  );
  ref.listen(appGateProvider, (previous, next) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
}
