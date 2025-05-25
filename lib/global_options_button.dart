import 'package:flutter/material.dart';
import 'customize_general_style_screen.dart';
import 'event.dart';
import 'event_provider.dart';
import 'package:provider/provider.dart';
import 'customize_perforated_style_screen.dart';

class GlobalOptionsButton extends StatelessWidget {
  final BuildContext context;
  final String currentScreen;
  final Event? event;
  final VoidCallback? onStartSelection;
  final VoidCallback? onLoadMockEvents;
  final VoidCallback? onShareSelection;
  final VoidCallback? onDeleteSelection;
  final VoidCallback? onAddQrCodes;
  final List<String> visibleOptions;
  final ValueChanged<Event>? onCustomizeSave;
  final List<String>? selectedQrCodes;
  final VoidCallback? onCustomizeSelect;



  const GlobalOptionsButton({
    super.key,
    required this.context,
    required this.currentScreen,
    this.event,
    this.onStartSelection,
    this.onLoadMockEvents,
    this.onShareSelection,
    this.onDeleteSelection,
    this.onAddQrCodes,
    this.onCustomizeSave,
    this.selectedQrCodes,
    this.visibleOptions = const ['select', 'share', 'delete', 'customize', 'add'],
    this.onCustomizeSelect,
  });

  @override
  Widget build(BuildContext _) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'customize':
              if (event != null) {
                if (event?.selectedTicketStyle.name == 'perforated') {
                  // Cas Perforated : on garde le menu All / Select
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Customize Tickets'),
                      content: const Text('Do you want to apply changes to all tickets or select specific ones?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final provider = Provider.of<EventProvider>(context, listen: false);
                            final index = provider.events.indexWhere((e) => e.id == event!.id);
                            if (index != -1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomizePerforatedStyleScreen(
                                    event: event!,
                                    targetQrCodes: selectedQrCodes!.isNotEmpty ? selectedQrCodes : null,
                                    onSave: (updated) {
                                      provider.updateEvent(index, updated);
                                      onCustomizeSave?.call(updated);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Apply to All'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (onStartSelection != null) {
                              onStartSelection!();
                            }
                            if (onCustomizeSelect != null) {
                              onCustomizeSelect!();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Select the QR codes to customize.')),
                            );
                          },
                          child: const Text('Select QRs'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Cas Classic, Centered, Minimal : on ouvre direct
                  final styleType = event!.selectedTicketStyle.name;
                  final provider = Provider.of<EventProvider>(context, listen: false);
                  final index = provider.events.indexWhere((e) => e.id == event!.id);
                  if (index != -1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomizeGeneralStyleScreen(
                          event: event!,
                          styleType: styleType,
                          onSave: (updated) {
                            provider.updateEvent(index, updated);
                            onCustomizeSave?.call(updated);
                          },
                        ),
                      ),
                    );
                  }
                }
              }
              break;

            case 'select':
              if (onStartSelection != null) {
                onStartSelection!();
              }
              break;

            case 'load':
              if (onLoadMockEvents != null) onLoadMockEvents!();
              break;

            case 'share':
              if (onShareSelection != null) {
                onShareSelection!();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select the QR codes you want to share.')),
                );
              }
              break;

            case 'delete':
              if (onStartSelection != null) {
                onStartSelection!();
                onDeleteSelection?.call();
              }
              break;

            case 'add':
              if (onAddQrCodes != null) onAddQrCodes!();
              break;
          }
        },

        itemBuilder: (context) => [
        if (visibleOptions.contains('select'))
          const PopupMenuItem(value: 'select', child: Text('🟦 Select')),
        if (visibleOptions.contains('customize') && event != null)
          const PopupMenuItem(value: 'customize', child: Text('🎨 Customize')),
        if (visibleOptions.contains('load'))
          const PopupMenuItem(value: 'load', child: Row(children: [Icon(Icons.bug_report, size: 18), SizedBox(width: 8), Text('Load test events')])),
        if (visibleOptions.contains('share'))
          const PopupMenuItem(value: 'share', child: Text('📤 Share')),
        if (visibleOptions.contains('add') && currentScreen == 'event_detail')
          const PopupMenuItem(value: 'add', child: Text('➕ Add QR Codes')),
        if (visibleOptions.contains('delete'))
          const PopupMenuItem(value: 'delete', child: Text('🗑️ Delete')),
      ],
    );
  }
}
