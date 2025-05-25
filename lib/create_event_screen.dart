// Adaptation de CreateEventScreen avec les champs Location et Organizer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'event.dart';
import 'event_provider.dart';
import 'ticket_style.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventEndDateController = TextEditingController();
  final _eventStartTimeController = TextEditingController();
  final _eventEndTimeController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _numberOfQrCodesController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();

  EventType _eventType = EventType.short;
  TicketStyle _ticketStyle = TicketStyle.classic;
  File? _eventImage;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _eventImage = File(image.path));
    }
  }

  Future<void> _pickDate({required TextEditingController controller, required bool isEndDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (!isEndDate) _selectedDate = picked;
        controller.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && _selectedDate != null) {
      final now = DateTime.now();
      final fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        picked.hour,
        picked.minute,
      );

      if (_selectedDate!.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) && fullDateTime.isBefore(now)) {
        _showSnackBar("L'heure ne peut pas être dans le passé.");
        return;
      }

      if (!isStart && _startTime != null) {
        final startTotal = _startTime!.hour * 60 + _startTime!.minute;
        final endTotal = picked.hour * 60 + picked.minute;
        if (endTotal <= startTotal) {
          _showSnackBar("L'heure de fin doit être après l'heure de début.");
          return;
        }
      }

      setState(() {
        if (isStart) _startTime = picked;
        controller.text = picked.format(context);
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _saveEvent() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final newEvent = Event(
      id: DateTime.now().toIso8601String(),
      name: _eventNameController.text,
      type: _eventType,
      date: _eventDateController.text,
      startTime: _eventStartTimeController.text,
      endTime: _eventEndTimeController.text,
      endDate: _eventType == EventType.long ? _eventEndDateController.text : null,
      description: _eventDescriptionController.text,
      numberOfQrCodes: int.tryParse(_numberOfQrCodesController.text) ?? 0,
      location: _locationController.text,
      organizer: _organizerController.text,
      image: _eventImage,
      perforatedShowImage: _eventImage != null,
      selectedTicketStyle: _ticketStyle,
    );
    eventProvider.addEvent(newEvent, context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<EventType>(
                value: _eventType,
                items: const [
                  DropdownMenuItem(value: EventType.short, child: Text("Short Event")),
                  DropdownMenuItem(value: EventType.long, child: Text("Long Event")),
                ],
                onChanged: (value) => setState(() => _eventType = value!),
              ),
              ListTile(
                title: const Text("🎨 Ticket Style"),
                subtitle: Text(_ticketStyle.name.toUpperCase()),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final selected = await showTicketStyleSelector(context, _ticketStyle);
                  if (selected != null) setState(() => _ticketStyle = selected);
                },
              ),
              TextField(controller: _eventNameController, decoration: const InputDecoration(labelText: 'Event Name')),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: _organizerController, decoration: const InputDecoration(labelText: 'Organizer')),
              TextField(
                controller: _eventDateController,
                decoration: const InputDecoration(labelText: 'Start Date'),
                readOnly: true,
                onTap: () => _pickDate(controller: _eventDateController, isEndDate: false),
              ),
              if (_eventType == EventType.long)
                TextField(
                  controller: _eventEndDateController,
                  decoration: const InputDecoration(labelText: 'End Date'),
                  readOnly: true,
                  onTap: () => _pickDate(controller: _eventEndDateController, isEndDate: true),
                ),
              TextField(
                controller: _eventStartTimeController,
                decoration: const InputDecoration(labelText: 'Start Time'),
                readOnly: true,
                onTap: () => _pickTime(_eventStartTimeController, isStart: true),
              ),
              TextField(
                controller: _eventEndTimeController,
                decoration: const InputDecoration(labelText: 'End Time'),
                readOnly: true,
                onTap: () => _pickTime(_eventEndTimeController, isStart: false),
              ),
              TextField(controller: _eventDescriptionController, decoration: const InputDecoration(labelText: 'Description (Optional)')),
              TextField(controller: _numberOfQrCodesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Number of QR Codes')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _pickImage, child: const Text('Select Image (Optional)')),
              if (_eventImage != null) Image.file(_eventImage!, height: 150, width: 150, fit: BoxFit.cover),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveEvent, child: const Text('Save Event')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    _eventDateController.dispose();
    _eventEndDateController.dispose();
    _eventStartTimeController.dispose();
    _eventEndTimeController.dispose();
    _eventDescriptionController.dispose();
    _numberOfQrCodesController.dispose();
    super.dispose();
  }
}