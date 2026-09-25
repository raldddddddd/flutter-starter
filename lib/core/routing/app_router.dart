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
      if (kEnableComponentShowcase && config.environment != AppEnvironment.prod)
        GoRoute(
          path: '/showcase',
          builder: (context, state) => const ComponentShowcaseScreen(),
        ),
    ],
    redirect: (context, state) {
      final gate = ref.read(appGateProvider);
      final isBootstrapping = gate == AppGateState.bootstrapping;
      final onBootstrap = state.matchedLocation == '/bootstrap';
      if (isBootstrapping && !onBootstrap) return '/bootstrap';
      if (!isBootstrapping && onBootstrap) return '/';
      return null;
    },
  );
  ref.listen(appGateProvider, (previous, next) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
}
