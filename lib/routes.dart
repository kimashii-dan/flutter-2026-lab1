import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/screens/detail_screen.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
}

class DetailArgs {
  const DetailArgs({required this.event, required this.userName});

  final Event event;
  final String userName;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  return switch ((settings.name, settings.arguments)) {
    (Routes.detail, DetailArgs args) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
    _ => null,
  };
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
