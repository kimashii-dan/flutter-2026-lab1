import 'dart:async';

import 'package:flutter/material.dart';

import 'package:campus_events/models/countdown.dart';
import 'package:campus_events/models/event.dart';
import 'package:campus_events/routes.dart';
import 'package:campus_events/utils/format.dart';
import 'package:campus_events/widgets/confirm.dart';
import 'package:campus_events/widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event _event = widget.args.event;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _register() async {
    final me = widget.args.userName;
    if (me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.args.onOpenProfile,
          ),
        ),
      );
      return;
    }
    final ok = await confirm(context, 'Register?', 'Add $me to the list?');
    if (!ok || !mounted) return;
    setState(
      () => _event = _event.copyWith(attendees: [..._event.attendees, me]),
    );
    widget.args.onChanged(_event);
  }

  void _unregister() {
    final me = widget.args.userName;
    setState(
      () => _event = _event.copyWith(
        attendees: _event.attendees.where((name) => name != me).toList(),
      ),
    );
    widget.args.onChanged(_event);
  }

  Future<void> _edit() async {
    final event = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormArgs(event: _event),
    );
    if (event == null || !mounted) return;
    setState(() => _event = event);
    widget.args.onChanged(event);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      'Delete event?',
      'This cannot be undone.',
    );
    if (!ok || !mounted) return;
    widget.args.onDelete(_event);
    Navigator.pop(context);
  }

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
    final registered = _event.contains(me);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_event.title),
          actions: [
            PopupMenuButton<VoidCallback>(
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(value: _edit, child: const Text('Edit')),
                PopupMenuItem(value: _delete, child: const Text('Delete')),
              ],
            ),
          ],
        ),
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
                        title: const Text('Starts'),
                        subtitle: Text(formatDateTime(_event.startsAt)),
                      ),
                      ListTile(
                        title: Text(_event.online ? 'Link' : 'Place'),
                        subtitle: Text(_event.location),
                      ),
                      ListTile(
                        title: const Text('Places'),
                        subtitle: Text('$taken taken, $free free'),
                      ),
                      if (_event.description case final description?)
                        ListTile(
                          title: const Text('Description'),
                          subtitle: Text(description),
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
                                title: Text(name),
                                selected: name == me,
                                trailing: name == me ? const Text('You') : null,
                              ),
                          ],
                        ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: registered
                      ? OutlinedButton(
                          onPressed: _unregister,
                          child: const Text('Unregister'),
                        )
                      : FilledButton(
                          onPressed: _event.isFull ? null : _register,
                          child: const Text('Register'),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
