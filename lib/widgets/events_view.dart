import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/widgets/event_card.dart';

class EventsView extends StatelessWidget {
  const EventsView({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;

  Widget _card(Event event) => EventCard(
    event: event,
    onTap: () => onOpen(event),
    onFavourite: () => onFavourite(event),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (_, index) => _card(events[index]),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                childAspectRatio: 2,
              ),
              itemCount: events.length,
              itemBuilder: (_, index) => _card(events[index]),
            ),
    );
  }
}
