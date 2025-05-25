import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'event_provider.dart';
import 'general_ticket_settings.dart';
import 'ticket_style.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  final int index;

  const EditEventScreen({super.key, required this.event, required this.index});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _endDateCtrl;
  late final TextEditingController _startTimeCtrl;
  late final TextEditingController _endTimeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _organizerCtrl;
  bool _perforatedShowImage = true;
  GeneralTicketSettings? _generalClassicSettings;
  GeneralTicketSettings? _generalCenteredSettings;
  GeneralTicketSettings? _generalMinimalSettings;
  File? _perforatedBackgroundImage;
  double _perforatedImageOpacity = 0.0;


  EventType _eventType = EventType.short;
  TicketStyle _ticketStyle = TicketStyle.classic;
  File? _eventImage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.event.name);
    _dateCtrl = TextEditingController(text: widget.event.date);
    _endDateCtrl = TextEditingController(text: widget.event.endDate ?? '');
    _startTimeCtrl = TextEditingController(text: widget.event.startTime);
    _endTimeCtrl = TextEditingController(text: widget.event.endTime);
    _descCtrl = TextEditingController(text: widget.event.description);
    _locationCtrl = TextEditingController(text: widget.event.location);
    _organizerCtrl = TextEditingController(text: widget.event.organizer);
    _eventType = widget.event.type;
    _eventImage = widget.event.image;
    _ticketStyle = widget.event.selectedTicketStyle;
    _perforatedShowImage = widget.event.perforatedShowImage;
    _generalClassicSettings = widget.event.generalClassicSettings;
    _generalCenteredSettings = widget.event.generalCenteredSettings;
    _generalMinimalSettings = widget.event.generalMinimalSettings;
    _perforatedBackgroundImage = widget.event.perforatedBackgroundImage;
    _perforatedImageOpacity = widget.event.perforatedImageOpacity ?? 1.0;

  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _eventImage = File(image.path));
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.text = picked.toIso8601String().split('T').first;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) controller.text = picked.format(context);
  }

  void _save() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final updated = widget.event.copyWith(
      name: _nameCtrl.text,
      type: _eventType,
      date: _dateCtrl.text,
      startTime: _startTimeCtrl.text,
      endTime: _endTimeCtrl.text,
      endDate: _eventType == EventType.long ? _endDateCtrl.text : null,
      description: _descCtrl.text,
      location: _locationCtrl.text,
      organizer: _organizerCtrl.text,
      numberOfQrCodes: widget.event.numberOfQrCodes,
      image: _eventImage,
      qrCodes: widget.event.qrCodes,
      selectedTicketStyle: _ticketStyle,

      // ✅ Ces lignes assurent qu'on garde tout
      perforatedShowImage: _perforatedShowImage,
      generalClassicSettings: _generalClassicSettings,
      generalCenteredSettings: _generalCenteredSettings,
      generalMinimalSettings: _generalMinimalSettings,
      perforatedBackgroundImage: _perforatedBackgroundImage,
      perforatedImageOpacity: _perforatedImageOpacity,
      customPerforatedSettings: widget.event.customPerforatedSettings,
      sharedQRCodes: widget.event.sharedQRCodes,
      usedQRCodes: widget.event.usedQRCodes,
    );

    eventProvider.updateEvent(widget.index, updated);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _endDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
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
                onChanged: (val) => setState(() => _eventType = val!),
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
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Event Name')),
              TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
              TextField(controller: _organizerCtrl, decoration: const InputDecoration(labelText: 'Organizer')),
              TextField(controller: _dateCtrl, readOnly: true, onTap: () => _pickDate(_dateCtrl), decoration: const InputDecoration(labelText: 'Start Date')),
              if (_eventType == EventType.long)
                TextField(controller: _endDateCtrl, readOnly: true, onTap: () => _pickDate(_endDateCtrl), decoration: const InputDecoration(labelText: 'End Date')),
              TextField(controller: _startTimeCtrl, readOnly: true, onTap: () => _pickTime(_startTimeCtrl), decoration: const InputDecoration(labelText: 'Start Time')),
              TextField(controller: _endTimeCtrl, readOnly: true, onTap: () => _pickTime(_endTimeCtrl), decoration: const InputDecoration(labelText: 'End Time')),
              TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _pickImage, child: const Text('Change Image')),
              if (_eventImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(_eventImage!, height: 150, width: 150, fit: BoxFit.cover),
                ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _save, child: const Text('Update Event')),
            ],
          ),
        ),
      ),
    );
  }
}