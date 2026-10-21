import 'package:flutter/material.dart';

import 'package:campus_events/models/countdown.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  sport('Sport', Icons.sports_soccer),
  music('Music', Icons.music_note),
  art('Art', Icons.palette),
  science('Science', Icons.science);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.sport => scheme.secondary,
    EventCategory.music => scheme.tertiary,
    EventCategory.art => scheme.error,
    EventCategory.science => scheme.outline,
  };
}

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.location,
    required this.capacity,
    this._attendees = const [],
    this.online = false,
    this.description,
    this.favourite = false,
  });

  Event.empty()
    : id = DateTime.now().microsecondsSinceEpoch.toString(),
      title = '',
      category = EventCategory.tech,
      startsAt = DateTime.now(),
      location = '',
      capacity = 20,
      _attendees = const [],
      online = false,
      description = null,
      favourite = false;

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final String location;
  final int capacity;
  final List<String> _attendees;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get attendees => List.unmodifiable(_attendees);

  int get count => _attendees.length;

  int get free => capacity - count;

  bool get isFull => free <= 0;

  bool get isPast => startsAt.isBefore(DateTime.now());

  bool contains(String name) => _attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Countdown get countdown {
    final now = DateTime.now();
    if (now.isBefore(startsAt)) return Upcoming(startsAt.difference(now));
    final elapsed = now.difference(startsAt);
    return elapsed < const Duration(hours: 2)
        ? Started(elapsed)
        : const Ended();
  }

  Event copyWith({
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    String? location,
    int? capacity,
    List<String>? attendees,
    bool? online,
    String? description,
    bool? favourite,
  }) => Event(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    location: location ?? this.location,
    capacity: capacity ?? this.capacity,
    attendees: attendees ?? _attendees,
    online: online ?? this.online,
    description: description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
