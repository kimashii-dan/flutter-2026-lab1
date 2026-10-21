import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavourite,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (taken: _, :free) = event.places;

    Widget badge(String label) => Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: text.labelSmall?.copyWith(color: scheme.onError),
          ),
        ),
      ),
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 56,
                child: Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: scheme.surfaceContainerHighest,
                        child: Icon(
                          event.category.icon,
                          color: event.category.color(scheme),
                        ),
                      ),
                    ),
                    if (event.isFull)
                      badge('FULL')
                    else if (free <= 5)
                      badge('$free left'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(formatDateTime(event.startsAt), style: text.bodySmall),
                    Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                icon: Icon(
                  event.favourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
