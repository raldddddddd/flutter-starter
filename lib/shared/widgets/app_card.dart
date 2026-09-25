import 'package:flutter/material.dart';

import '../../core/design/app_layout_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(context.layout.spaceMd),
      child: child,
    ),
  );
}
