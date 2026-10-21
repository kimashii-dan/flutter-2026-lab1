import 'package:flutter/material.dart';

import 'package:campus_events/models/countdown.dart';
import 'package:campus_events/models/event.dart';
import 'package:campus_events/routes.dart';
import 'package:campus_events/utils/format.dart';
import 'package:campus_events/widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Event _event = widget.args.event;

  String _countdownText(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'In ${formatDuration(left)}',
    Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (:taken, :free) = _event.places;
    final me = widget.args.userName;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(_event.title)),
        body: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/header.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Icon(
                    _event.category.icon,
                    size: 64,
                    color: scheme.onPrimary,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Chip(label: Text(_event.category.label)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Chip(label: Text(_countdownText(_event.countdown))),
                ),
              ],
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Attendees ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(formatDateTime(_event.startsAt)),
                      ),
                      ListTile(
                        leading: Icon(_event.online ? Icons.link : Icons.place),
                        title: Text(_event.location),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: Text('$taken / ${_event.capacity} taken'),
                        subtitle: Text('$free free'),
                      ),
                      if (_event.description case final description?)
                        ListTile(
                          leading: const Icon(Icons.notes),
                          title: Text(description),
                        ),
                    ],
                  ),
                  _event.count == 0
                      ? const EmptyState(
                          icon: Icons.group_off,
                          message: 'Nobody is registered yet',
                        )
                      : ListView(
                          children: [
                            for (final name in _event.attendees)
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(name),
                                selected: name == me,
                                trailing: name == me ? const Text('You') : null,
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
