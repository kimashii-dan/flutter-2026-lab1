import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Z]{2,5}-\d{2,4}$');

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != oldWidget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (widget.profile.group != oldWidget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final group = value?.trim() ?? '';
    return group.isEmpty || _groupPattern.hasMatch(group)
        ? null
        : 'Use the format SE-2203';
  }

  void _saveGroup(String value) {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onChanged(widget.profile.copyWith(group: value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    final lists = widget.events.fold(
      0,
      (count, e) => e.contains(name) ? count + 1 : count,
    );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) =>
                widget.onChanged(widget.profile.copyWith(name: value.trim())),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _group,
            decoration: const InputDecoration(
              labelText: 'Group',
              hintText: 'SE-2203',
            ),
            textInputAction: TextInputAction.done,
            validator: _validateGroup,
            onFieldSubmitted: _saveGroup,
          ),
          const SizedBox(height: 24),
          Text(
            'You are on $lists lists',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(mode.name),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
