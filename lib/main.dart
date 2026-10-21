import 'package:flutter/material.dart';

import 'package:campus_events/routes.dart';
import 'package:campus_events/screens/shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Events',
      routes: {Routes.home: (_) => const Shell()},
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}
