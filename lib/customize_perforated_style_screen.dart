import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_event_app/perforated_ticket_settings.dart';
import 'event.dart';
import 'perforated_ticket_card.dart';

class CustomizePerforatedStyleScreen extends StatefulWidget {
  final Event event;
  final String? qrCode;
  final ValueChanged<Event> onSave;
  final List<String>? targetQrCodes;


  const CustomizePerforatedStyleScreen({
    super.key,
    required this.event,
    this.qrCode,
    this.targetQrCodes,
    required this.onSave,
  });

  @override
  State<CustomizePerforatedStyleScreen> createState() => _CustomizePerforatedStyleScreenState();
}

class _CustomizePerforatedStyleScreenState extends State<CustomizePerforatedStyleScreen> {
  late Color bgColor;
  late Color textColor;
  bool showLocation = true;
  bool showOrganizer = true;
  bool showImage = true;
  int style = 1;
  String importantLabel = '';
  late TextEditingController _labelController;
  late Event previewEvent;
  double imageOpacity = 0.0;
  File? backgroundImage;



  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    loadPreviewSettingsFromCurrentState();
  }

  void loadPreviewSettingsFromCurrentState() {
    final referenceQrCode = widget.qrCode ?? widget.targetQrCodes?.first;
    final individualSettings = referenceQrCode != null
        ? widget.event.customPerforatedSettings[referenceQrCode]
        : null;

    bgColor = individualSettings?.bgColor ?? widget.event.perforatedBackgroundColor;
    textColor = individualSettings?.textColor ?? widget.event.perforatedTextColor;
    showLocation = individualSettings?.showLocation ?? widget.event.perforatedShowLocation;
    showOrganizer = individualSettings?.showOrganizer ?? widget.event.perforatedShowOrganizer;
    showImage = individualSettings?.showImage ?? widget.event.perforatedShowImage;
    style = individualSettings?.variant ?? widget.event.perforatedVariant;
    importantLabel = individualSettings?.label ?? widget.event.perforatedImportantLabel;
    imageOpacity = individualSettings?.imageOpacity ?? widget.event.perforatedImageOpacity ?? 0.0;
    backgroundImage = individualSettings?.backgroundImage ?? widget.event.perforatedBackgroundImage;

    _labelController.text = importantLabel;

    previewEvent = widget.event.copyWith(
      perforatedBackgroundColor: bgColor,
      perforatedTextColor: textColor,
      perforatedShowLocation: showLocation,
      perforatedShowOrganizer: showOrganizer,
      perforatedShowImage: showImage,
      perforatedVariant: style,
      perforatedImportantLabel: importantLabel,
      perforatedImageOpacity: imageOpacity,
      perforatedBackgroundImage: backgroundImage,
    );
  }

  Future<void> pickColor(Color currentColor, ValueChanged<Color> onColorPicked) async {
    final newColor = await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: onColorPicked,
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
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );

    if (newColor != null) {
      onColorPicked(newColor);
      updatePreview();
    }
  }

  void updatePreview() {
    setState(() {
      previewEvent = previewEvent.copyWith(
        perforatedBackgroundColor: bgColor,
        perforatedTextColor: textColor,
        perforatedShowLocation: showLocation,
        perforatedShowOrganizer: showOrganizer,
        perforatedShowImage: showImage,
        perforatedVariant: style,
        perforatedImportantLabel: _labelController.text.trim(),
        perforatedImageOpacity: imageOpacity,
        perforatedBackgroundImage: backgroundImage,

      );

    });
  }

  @override
  Widget build(BuildContext context) {
    final previewQrCode = widget.qrCode ?? widget.targetQrCodes?.first ?? 'PREVIEW_QR';
    final previewQrNumber = widget.event.qrCodes.indexOf(previewQrCode) + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Customize Tickets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Colors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickColor(bgColor, (c) {
                      bgColor = c;
                      updatePreview();
                    }),
                    icon: const Icon(Icons.format_color_fill),
                    label: const Text('Background'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 30, height: 30, color: bgColor, margin: const EdgeInsets.only(right: 16)),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickColor(textColor, (c) {
                      textColor = c;
                      updatePreview();
                    }),
                    icon: const Icon(Icons.text_format),
                    label: const Text('Text'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 30, height: 30, color: textColor),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Background Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Image Opacity', style: TextStyle(fontWeight: FontWeight.w500)),
                      Slider(
                        value: imageOpacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(imageOpacity * 100).round()}%',
                        onChanged: (value) {
                          setState(() {
                            imageOpacity = value;
                            updatePreview();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setState(() {
                              backgroundImage = File(picked.path); // ✅ on met à jour la variable
                              updatePreview();
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Select Image'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (backgroundImage != null)
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: FileImage(backgroundImage!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(1 - imageOpacity),
                              BlendMode.dstATop,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 25),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              backgroundImage = null;
                              updatePreview();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(height: 32),
            const Text('Important Label', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(hintText: 'e.g. VIP, STAFF, PRESS'),
              onChanged: (value) {
                importantLabel = value.trim();
                updatePreview();
              },
            ),
            const Divider(height: 32),
            const Text('Ticket Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return Expanded(
                  child: RadioListTile<int>(
                    value: i + 1,
                    groupValue: style,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Style ${i + 1}'),
                    onChanged: (value) {
                      style = value!;
                      updatePreview();
                    },
                  ),
                );
              }),
            ),
            const Divider(height: 32),
            const Text('Fields to Show', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: showLocation,
                        onChanged: (v) {
                          setState(() {
                            showLocation = v!;
                            updatePreview();
                          });
                        },
                      ),
                      const Text('Show Location'),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: showOrganizer,
                        onChanged: (v) {
                          setState(() {
                            showOrganizer = v!;
                            updatePreview();
                          });
                        },
                      ),
                      const Text('Show Organizer'),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: showImage,
                        onChanged: (v) {
                          setState(() {
                            showImage = v!;
                            updatePreview();
                          });
                        },
                      ),
                      const Text('Show Image'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 32),
            const Text('Live Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
          Center(
            child: PerforatedTicketCard(
              qrCode: previewQrCode,
              qrNumber: previewQrNumber,
              event: previewEvent,
              isSelected: false,
              isShared: widget.event.sharedQRCodes[previewQrCode] ?? false,
              statusLabel: (widget.event.usedQRCodes[previewQrCode] ?? false)
                  ? 'Used'
                  : DateTime.now().isAfter(DateTime.parse(
                  '${widget.event.type == EventType.long ? widget.event.endDate : widget.event.date} ${widget.event.endTime}'))
                  ? 'Expired'
                  : 'Available',
              isForShare: true,
              hasImportantLabel: previewEvent.perforatedImportantLabel.trim().isNotEmpty,
            ),
          ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        bgColor = widget.event.perforatedBackgroundColor;
                        textColor = widget.event.perforatedTextColor;
                        showLocation = widget.event.perforatedShowLocation;
                        showOrganizer = widget.event.perforatedShowOrganizer;
                        showImage = widget.event.perforatedShowImage;
                        style = widget.event.perforatedVariant;
                        importantLabel = widget.event.perforatedImportantLabel;
                        _labelController.text = importantLabel;
                        imageOpacity = widget.event.perforatedImageOpacity ?? 0.0;
                        previewEvent = widget.event.copyWith(
                          perforatedBackgroundColor: widget.event.perforatedBackgroundColor,
                          perforatedTextColor: widget.event.perforatedTextColor,
                          perforatedShowLocation: widget.event.perforatedShowLocation,
                          perforatedShowOrganizer: widget.event.perforatedShowOrganizer,
                          perforatedShowImage: widget.event.perforatedShowImage,
                          perforatedVariant: widget.event.perforatedVariant,
                          perforatedImportantLabel: widget.event.perforatedImportantLabel,
                          perforatedBackgroundImage: widget.event.perforatedBackgroundImage,
                          perforatedImageOpacity: imageOpacity,
                        );
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final updatedSettings = PerforatedTicketSettings(
                        bgColor: bgColor,
                        textColor: textColor,
                        label: importantLabel,
                        showImage: showImage,
                        showLocation: showLocation,
                        showOrganizer: showOrganizer,
                        backgroundImage: previewEvent.perforatedBackgroundImage,
                        imageOpacity: imageOpacity,
                        variant: style,
                      );

                      final updatedMap = Map<String, PerforatedTicketSettings>.from(widget.event.customPerforatedSettings);

                      if (widget.qrCode != null) {
                        updatedMap[widget.qrCode!] = updatedSettings;
                      } else if (widget.targetQrCodes != null && widget.targetQrCodes!.isNotEmpty) {
                        for (final qr in widget.targetQrCodes!) {
                          updatedMap[qr] = updatedSettings;
                        }
                      } else {
                        for (final qr in widget.event.qrCodes) {
                          updatedMap[qr] = updatedSettings;
                        }
                      }

                      final updatedEvent = widget.event.copyWith(customPerforatedSettings: updatedMap);
                      widget.onSave(updatedEvent);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Apply to Ticket'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
