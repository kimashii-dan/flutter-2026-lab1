import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/widgets/empty_state.dart';
import 'package:campus_events/widgets/events_view.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = events.where((e) => e.favourite).toList();
    return favourites.isEmpty
        ? EmptyState(
            icon: Icons.favorite_border,
            message: 'No favourites yet',
            actionLabel: 'Browse events',
            onAction: onBrowse,
          )
        : EventsView(
            events: favourites,
            onOpen: onOpen,
            onFavourite: onFavourite,
          );
  }
}
