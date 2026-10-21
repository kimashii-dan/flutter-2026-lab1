import 'package:flutter/material.dart';

import 'package:campus_events/models/event.dart';
import 'package:campus_events/routes.dart';
import 'package:campus_events/utils/format.dart';
import 'package:campus_events/widgets/confirm.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _capacity = TextEditingController();
  final _description = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _locationFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  EventCategory? _category;
  DateTime? _date;
  TimeOfDay? _time;
  bool _online = false;
  bool _saving = false;
  late final Record _initial;

  bool get _isNew => widget.args.event == null;

  DateTime? get _startsAt => switch ((_date, _time)) {
    (final date?, final time?) => DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ),
    _ => null,
  };

  Record get _values => (
    _title.text,
    _location.text,
    _capacity.text,
    _description.text,
    _category,
    _date,
    _time,
    _online,
  );

  bool get _dirty => _values != _initial;

  @override
  void initState() {
    super.initState();
    final event = widget.args.event ?? Event.empty();
    _title.text = event.title;
    _location.text = event.location;
    _capacity.text = '${event.capacity}';
    _description.text = event.description ?? '';
    _online = event.online;
    if (widget.args.event case final existing?) {
      _category = existing.category;
      _date = existing.startsAt;
      _time = TimeOfDay.fromDateTime(existing.startsAt);
      _dateText.text = formatDate(existing.startsAt);
      _timeText.text = formatTime(
        existing.startsAt.hour,
        existing.startsAt.minute,
      );
    }
    _initial = _values;
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _capacity.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _locationFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final length = value?.trim().length ?? 0;
    return length < 3 || length > 60 ? 'Title must be 3–60 characters' : null;
  }

  String? _validateCategory(EventCategory? value) =>
      value == null ? 'Choose a category' : null;

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    final startsAt = _startsAt;
    if (_time == null) return 'Pick a time';
    if (_isNew && startsAt != null && startsAt.isBefore(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    final location = value?.trim() ?? '';
    if (location.isEmpty) return _online ? 'Enter a link' : 'Enter a location';
    if (_online && !location.contains('://')) return 'Link must contain ://';
    return null;
  }

  String? _validateCapacity(String? value) {
    final capacity = int.tryParse(value ?? '');
    final count = widget.args.event?.count ?? 0;
    if (capacity == null || capacity < 1 || capacity > 500) {
      return 'Enter a number from 1 to 500';
    }
    if (capacity < count) return 'Cannot be below $count registered';
    return null;
  }

  Future<void> _onPop(bool didPop, Event? result) async {
    if (didPop || _saving) return;
    final discard = await confirm(
      context,
      'Discard changes?',
      'Your changes will be lost.',
    );
    if (discard && mounted) Navigator.pop(context);
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _dateText.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeText.text = formatTime(picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    final (category, startsAt) = (_category, _startsAt);
    if (_saving ||
        !(_formKey.currentState?.validate() ?? false) ||
        category == null ||
        startsAt == null) {
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final base = widget.args.event ?? Event.empty();
    final description = _description.text.trim();
    Navigator.pop(
      context,
      Event(
        id: base.id,
        title: _title.text.trim(),
        category: category,
        startsAt: startsAt,
        location: _location.text.trim(),
        capacity: int.parse(_capacity.text),
        attendees: base.attendees,
        online: _online,
        description: description.isEmpty ? null : description,
        favourite: base.favourite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Event>(
      canPop: !_dirty,
      onPopInvokedWithResult: _onPop,
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  maxLength: 60,
                  validator: _validateTitle,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                  onTapOutside: _unfocus,
                ),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in EventCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                  validator: _validateCategory,
                ),
                TextFormField(
                  controller: _dateText,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                  validator: _validateDate,
                ),
                TextFormField(
                  controller: _timeText,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _pickTime,
                  validator: _validateTime,
                ),
                SwitchListTile(
                  title: const Text('Online'),
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                ),
                TextFormField(
                  controller: _location,
                  focusNode: _locationFocus,
                  decoration: InputDecoration(
                    labelText: _online ? 'Link' : 'Location',
                  ),
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  validator: _validateLocation,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                  onTapOutside: _unfocus,
                ),
                TextFormField(
                  controller: _capacity,
                  focusNode: _capacityFocus,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  validator: _validateCapacity,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  onTapOutside: _unfocus,
                ),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 3,
                  validator: (value) => (value?.length ?? 0) > 200
                      ? 'At most 200 characters'
                      : null,
                  textInputAction: TextInputAction.done,
                  onTapOutside: _unfocus,
                ),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
