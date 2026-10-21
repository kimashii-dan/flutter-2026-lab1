import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/screens/detail_screen.dart';
import 'package:campus_events/screens/form_screen.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Event event;
  final String userName;
  final ValueChanged<Event> onChanged;
  final ValueChanged<Event> onDelete;
  final VoidCallback onOpenProfile;
}

class FormArgs {
  const FormArgs({this.event});

  final Event? event;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  return switch ((settings.name, settings.arguments)) {
    (Routes.detail, DetailArgs args) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
    (Routes.form, FormArgs args) => MaterialPageRoute<Event>(
      settings: settings,
      builder: (_) => FormScreen(args: args),
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
