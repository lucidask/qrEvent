import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_event_app/event.dart';
import 'package:qr_event_app/general_ticket_settings.dart';

class CustomizeGeneralStyleScreen extends StatefulWidget {
  final Event event;
  final String styleType; // 'classic', 'centered', 'minimal'
  final ValueChanged<Event> onSave;

  const CustomizeGeneralStyleScreen({
    super.key,
    required this.event,
    required this.styleType,
    required this.onSave,
  });

  @override
  State<CustomizeGeneralStyleScreen> createState() => _CustomizeGeneralStyleScreenState();
}

class _CustomizeGeneralStyleScreenState extends State<CustomizeGeneralStyleScreen> {
  late Color bgColor;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    final settings = _getSettings();
    bgColor = settings?.bgColor ?? Colors.white;
    textColor = settings?.textColor ?? Colors.black;
  }

  GeneralTicketSettings? _getSettings() {
    switch (widget.styleType) {
      case 'classic': return widget.event.generalClassicSettings;
      case 'centered': return widget.event.generalCenteredSettings;
      case 'minimal': return widget.event.generalMinimalSettings;
      default: return null;
    }
  }

  void _save() {
    final updatedSettings = GeneralTicketSettings(bgColor: bgColor, textColor: textColor);
    final updatedEvent = widget.event.copyWith(
      generalClassicSettings: widget.styleType == 'classic' ? updatedSettings : widget.event.generalClassicSettings,
      generalCenteredSettings: widget.styleType == 'centered' ? updatedSettings : widget.event.generalCenteredSettings,
      generalMinimalSettings: widget.styleType == 'minimal' ? updatedSettings : widget.event.generalMinimalSettings,
    );
    widget.onSave(updatedEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Colors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final newColor = await pickColor(bgColor);
                      if (newColor != null) setState(() => bgColor = newColor);
                    },
                    icon: const Icon(Icons.format_color_fill),
                    label: const Text('Background'),
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 30, height: 30, color: bgColor),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final newColor = await pickColor(textColor);
                      if (newColor != null) setState(() => textColor = newColor);
                    },
                    icon: const Icon(Icons.text_format),
                    label: const Text('Text'),
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 30, height: 30, color: textColor),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            const Text('Live Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPreviewTicket(),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPreviewTicket() {
    switch (widget.styleType) {
      case 'centered':
        return _buildCenteredPreview();
      case 'minimal':
        return _buildMinimalPreview();
      case 'classic':
      default:
        return _buildClassicPreview();
    }
  }

  Widget _buildClassicPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(
            data: 'PREVIEW',
            size: 60,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🎟️ Ticket #001", style: TextStyle(color :textColor, fontWeight: FontWeight.bold)),
                Text("📌 ${widget.event.name}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
                Text("📌 ${widget.event.date} ${widget.event.startTime}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
                Text("📍 ${widget.event.location}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
                Text("👤 ${widget.event.organizer}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredPreview() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: 'PREVIEW',
            size: 70,
            backgroundColor: Colors.white, // 👈 arrière-plan blanc
          ),
          const SizedBox(height: 8),
          Text("🎟️ Ticket #001", style:  TextStyle( color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.event.name, style: TextStyle(color: textColor, fontSize: 14), overflow: TextOverflow.ellipsis),
            Text("${widget.event.date} ${widget.event.startTime}", style: TextStyle(color: textColor, fontSize: 13)),
            Text("📍 ${widget.event.location}", style: TextStyle(color: textColor, fontSize: 13)),
            Text("👤 ${widget.event.organizer}", style: TextStyle(color: textColor, fontSize: 13)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(data: 'PREVIEW', size: 60, backgroundColor: Colors.white,),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("🎟️ Ticket# 001 ", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(widget.event.name, style: TextStyle(color: textColor, fontSize: 13), overflow: TextOverflow.ellipsis,
                ),
                Text("${widget.event.date} ${widget.event.startTime}", style: TextStyle(color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> pickColor(Color currentColor) async {
    return showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            availableColors: [
              Colors.white,
              Colors.black,
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
              Colors.brown,
              Colors.grey,
              Colors.pink,
              Colors.cyan,
              Colors.teal,
              Colors.indigo,
              Colors.lime,
              Colors.amber,
              Colors.deepOrange,
              Colors.deepPurple,
              Colors.lightBlue,
              Colors.lightGreen,
              Colors.blueGrey,
            ],
            onColorChanged: (c) => Navigator.pop(context, c),
          ),
        ),
      ),
    );
  }
}
