import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_event_app/qr_scanner_screen.dart';
import 'create_event_screen.dart';
import 'edit_event_screen.dart';
import 'event.dart';
import 'event_detail_and_qr_code_screen.dart';
import 'event_provider.dart';
import 'global_options_button.dart';
import 'ticket_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool selectionMode = false;
  Set<String> selectedEventIds = {};
  bool isSearching = false;
  String searchQuery = '';

  void startSelection() {
    setState(() {
      selectionMode = true;
      selectedEventIds.clear();
    });
  }

  void cancelSelection() {
    setState(() {
      selectionMode = false;
      selectedEventIds.clear();
    });
  }

  void toggleSelectAll(List<String> allIds) {
    setState(() {
      if (selectedEventIds.length == allIds.length) {
        selectedEventIds.clear();
      } else {
        selectedEventIds = allIds.toSet();
      }
    });
  }

  void deleteSelected(BuildContext context) {
    final provider = context.read<EventProvider>();
    final events = provider.events;
    for (int i = events.length - 1; i >= 0; i--) {
      if (selectedEventIds.contains(events[i].id)) {
        provider.removeEvent(i);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Selected events deleted')),
    );
    cancelSelection();
  }

  void _showEventOptions(BuildContext context, int index, Event event) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (choice == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditEventScreen(event: event, index: index),
        ),
      );
    } else if (choice == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm deletion'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirm == true) {
        context.read<EventProvider>().removeEvent(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully!')),
        );
      }
    }
  }

  String ticketStyleToString(TicketStyle style) {
    switch (style) {
      case TicketStyle.classic:
        return 'Classic';
      case TicketStyle.centered:
        return 'Centered';
      case TicketStyle.minimal:
        return 'Minimal';
      case TicketStyle.perforated:
        return 'Perforated';
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final allEventIds = eventProvider.events.map((e) => e.id).toList();
    final allSelected = selectedEventIds.length == allEventIds.length && allEventIds.isNotEmpty;
    final filteredEvents = isSearching ? eventProvider.events.where((event) {
      final query = searchQuery.toLowerCase();
      return event.name.toLowerCase().contains(query) ||
          event.description.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.organizer.toLowerCase().contains(query);
    }).toList()
        : eventProvider.events;


    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: !isSearching
            ? Text(selectionMode ? 'Selected (${selectedEventIds.length})' : 'Event List')
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search events...',
              border: InputBorder.none,
            ),
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
        ),
        leading: selectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: cancelSelection,
        )
            : IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              searchQuery = '';
            });
          },
        ),
        actions: [
          if (selectionMode)
            IconButton(
              icon: Icon(allSelected ? Icons.remove_done : Icons.select_all),
              tooltip: allSelected ? 'Unselect all' : 'Select all',
              onPressed: () => toggleSelectAll(allEventIds),
            )
          else
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                );
              },
            ),
          if (!selectionMode)
            GlobalOptionsButton(
              context: context,
              currentScreen: 'home',
              event: eventProvider.events.isNotEmpty ? eventProvider.events.first : null,
              onStartSelection: startSelection,
              visibleOptions: const ['select', 'load'],
              onLoadMockEvents: () {
                Provider.of<EventProvider>(context, listen: false).loadMockEvents();
                Provider.of<EventProvider>(context, listen: false).saveMockEventsToHive();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✔️ Test events added')),
                );
              },
            ),
        ],
      ),

      body: ListView.separated(
        itemCount: filteredEvents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          final isSelected = selectedEventIds.contains(event.id);

          return GestureDetector(
            onTap: selectionMode
                ? () => setState(() {
              isSelected ? selectedEventIds.remove(event.id) : selectedEventIds.add(event.id);
            })
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailAndQRCodeScreen(event: event),
                ),
              );
            },
            onLongPress: () => _showEventOptions(context, index, event),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isSelected ? Colors.blue.shade100 : Colors.blue.withOpacity(0.3),
                    isSelected ? Colors.blue.shade50 : Colors.lightBlue.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: selectionMode
                    ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => setState(() {
                    isSelected ? selectedEventIds.remove(event.id) : selectedEventIds.add(event.id);
                  }),
                )
                    : event.image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    event.image!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.event, size: 40, color: Colors.white),
                title: Text(
                  event.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📅 ${event.date}", style: const TextStyle(color: Colors.white70)),
                    Text("🕒 ${event.startTime} - ${event.endTime}", style: const TextStyle(color: Colors.white70)),
                    Text("🎟️ Ticket Style: ${ticketStyleToString(event.selectedTicketStyle)}", style: const TextStyle(color: Colors.white70)),
                    if (event.description.isNotEmpty)
                      Text("📝 ${event.description}", style: const TextStyle(color: Colors.white70)),
                    Text("🔢 QR Codes: ${event.qrCodes.length}", style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: selectionMode && selectedEventIds.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => deleteSelected(context),
        label: const Text('Delete selection'),
        icon: const Icon(Icons.delete_forever),
      )
          : FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
