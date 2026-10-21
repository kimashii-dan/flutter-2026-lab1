import 'package:flutter/material.dart';

import 'package:campus_events/data/seed.dart';
import 'package:campus_events/models/event.dart';
import 'package:campus_events/models/profile.dart';
import 'package:campus_events/routes.dart';
import 'package:campus_events/screens/favourites_tab.dart';
import 'package:campus_events/screens/list_tab.dart';
import 'package:campus_events/screens/profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Event> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _update(Event event) {
    setState(
      () => _events = [for (final e in _events) e.id == event.id ? event : e],
    );
  }

  void _delete(Event event) {
    setState(() => _events = _events.where((e) => e.id != event.id).toList());
  }

  void _toggleFavourite(Event event) =>
      _update(event.copyWith(favourite: !event.favourite));

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  void _openDetail(Event event) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        userName: _profile.name,
        onChanged: _update,
        onDelete: _delete,
        onOpenProfile: _openProfile,
      ),
    );
  }

  Future<void> _create() async {
    final event = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (event == null || !mounted) return;
    setState(() => _events = [..._events, event]);
  }

  void _openProfile() {
    Navigator.popUntil(context, (route) => route.isFirst);
    _goTo(2);
  }

  void _goTo(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(const ['Events', 'Favourites', 'Profile'][_tab]),
      ),
      body: switch (_tab) {
        0 => ListTab(
          events: _events,
          onOpen: _openDetail,
          onFavourite: _toggleFavourite,
        ),
        1 => FavouritesTab(
          events: _events,
          onOpen: _openDetail,
          onFavourite: _toggleFavourite,
          onBrowse: () => _goTo(0),
        ),
        _ => ProfileTab(
          profile: _profile,
          events: _events,
          onChanged: _setProfile,
        ),
      },
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _create,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
