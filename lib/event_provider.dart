import 'package:flutter/material.dart';
import 'package:qr_event_app/model/event_hive_model.dart';
import 'package:qr_event_app/ticket_style.dart';
import 'package:uuid/uuid.dart';
import 'event.dart';
import 'database/hive_service.dart';


class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];
  List<Event> get events => _events;

  final HiveService _hiveService = HiveService();

  // Load events from Hive
  Future<void> loadEvents() async {
    try {
      final hiveEvents = _hiveService.getAllEvents();
      _events.clear();
      _events.addAll(hiveEvents.cast<EventHiveModel>().map((e) => e.toEvent()));
      notifyListeners();
    } catch (e) {
      debugPrint('errors when loading events : $e');
    }
  }

  // Add a new event
  Future<bool> addEvent(Event event, BuildContext context) async {

    final exists = _events.any((e) =>
    e.name == event.name &&
        e.date == event.date &&
        e.startTime == event.startTime &&
        e.endTime == event.endTime
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event already exists.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    final hiveEvent = event.toHiveModel();
    await _hiveService.saveEvent(hiveEvent);

    _events.add(event);
    notifyListeners();
    return true;
  }

  // Remove an event
  Future<void> removeEvent(int index) async {
    if (index < 0 || index >= _events.length) return;

    final eventId = _events[index].id;
    await _hiveService.deleteEvent(eventId);

    _events.removeAt(index);
    notifyListeners();
  }

  // Update an event
  Future<void> updateEvent(int index, Event newEvent) async {
    if (index < 0 || index >= _events.length) return;
    _events[index].id;

    final hiveEvent = newEvent.toHiveModel();
    await _hiveService.saveEvent(hiveEvent);

    _events[index] = newEvent;
    notifyListeners();
  }

  void loadMockEvents() {
    final now = DateTime.now();
    final styles = TicketStyle.values;

    for (int i = 0; i < styles.length; i++) {
      final date = now.add(Duration(days: i));
      final qrCodes = List.generate(10, (_) => const Uuid().v4());

      final mockEvent = Event(
        id: DateTime.now().toIso8601String(),
        name: 'Test Event ${i + 1}',
        type: EventType.short,
        date: date.toIso8601String().split('T').first,
        startTime: '10:00',
        endTime: '12:00',
        endDate: null,
        description: 'This is a test event with ${styles[i].name} style.',
        location: 'Test Location ${i + 1}',
        organizer: 'Organizer ${i + 1}',
        numberOfQrCodes: 10,
        image: null,
        selectedTicketStyle: styles[i],
        qrCodes: qrCodes,
      );

      _events.add(mockEvent);
    }

    notifyListeners();
  }

  Future<void> saveMockEventsToHive() async {
    for (final event in _events) {
      await _hiveService.saveEvent(event.toHiveModel());
    }
  }


  Future<void> clearAllEvents() async {
    await _hiveService.clearAll();
    _events.clear();
    notifyListeners();
  }

  bool _initiatedFromCustomize = false;
  bool get initiatedFromCustomize => _initiatedFromCustomize;
  void setInitiatedFromCustomize(bool value) {
    _initiatedFromCustomize = value;
    notifyListeners();
  }
}
