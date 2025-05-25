import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'customize_perforated_style_screen.dart';
import 'event.dart';
import 'event_provider.dart';
import 'export_button_pdf.dart';
import 'global_options_button.dart';
import 'share_qr_code_image.dart';
import 'dart:math';
import 'classic_ticket_card.dart';
import 'perforated_ticket_card.dart';
import 'minimal_ticket_card.dart';
import 'centered_ticket_card.dart';
import 'ticket_style.dart';

class EventDetailAndQRCodeScreen extends StatefulWidget {
  final Event event;
  const EventDetailAndQRCodeScreen({super.key, required this.event});

  @override
  State<EventDetailAndQRCodeScreen> createState() => _EventDetailAndQRCodeScreenState();
}

class _EventDetailAndQRCodeScreenState extends State<EventDetailAndQRCodeScreen> with TickerProviderStateMixin {
  final Set<String> selectedQRCodes = {};
  bool selectionMode = false;
  String qrFilter = 'All';
  String qrStatusFilter = 'All';
  bool isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 50;
  bool useGrid = true;
  bool initiatedFromShare = false;
  bool initiatedFromDelete = false;
  bool initiatedFromCustomize = false;
  late Event event;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  void _deleteSelectedQRCodes() async {
    if (selectedQRCodes.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Delete ${selectedQRCodes.length} QR code(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      event.qrCodes.removeWhere(selectedQRCodes.contains);
      for (var code in selectedQRCodes) {
        event.usedQRCodes.remove(code);
        event.sharedQRCodes.remove(code);
      }
      selectedQRCodes.clear();
      selectionMode = false;
    });
    _saveEvent();
  }

  void _saveEvent() {
    final provider = Provider.of<EventProvider>(context, listen: false);
    final index = provider.events.indexOf(event);
    provider.updateEvent(index, event);
  }

  void _toggleSelectAll() {
    setState(() {
      final filteredCodes = event.qrCodes.where((code) {
        final isUsed = event.usedQRCodes[code] ?? false;
        final isExpired = !isUsed && DateTime.now().isAfter(
            DateTime.parse('${event.type == EventType.long ? event.endDate : event.date} ${event.endTime}')
        );
        final isAvailable = !isUsed && !isExpired;
        final isShared = event.sharedQRCodes[code] ?? false;

        if (qrStatusFilter == 'Used' && !isUsed) return false;
        if (qrStatusFilter == 'Expired' && !isExpired) return false;
        if (qrStatusFilter == 'Available' && !isAvailable) return false;
        if (qrFilter == 'Shared' && !isShared) return false;
        if (qrFilter == 'Unshared' && isShared) return false;

        return true;
      }).toList();

      final paged = filteredCodes.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

      if (paged.every((code) => selectedQRCodes.contains(code))) {
        selectedQRCodes.removeAll(paged);
      } else {
        selectedQRCodes.addAll(paged);
      }
    });
  }

  void _cancelSelection() => setState(() {
    selectedQRCodes.clear();
    selectionMode = false;
  });

  void _shareSelected() {
    if (selectedQRCodes.isEmpty) return;

    setState(() {
      for (var code in selectedQRCodes) {
        event.sharedQRCodes[code] = true;
      }
    });
    _saveEvent();

    QRShareHelper.shareMultipleQRCodes(
      context,
      event: event,
      qrDataList: selectedQRCodes.toList(),
      prefix: event.name.replaceAll(' ', '_'),
    ).then((_) => setState(() {}));
  }

  void _showAddQrDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add QR Codes'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Number of QR Codes'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final count = int.tryParse(controller.text);
              if (count != null && count > 0) {
                setState(() {
                  for (int i = 0; i < count; i++) {
                    final code = const Uuid().v4();
                    event.qrCodes.add(code);
                    event.usedQRCodes[code] = false;
                    event.sharedQRCodes[code] = false;
                  }
                });
                _saveEvent();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endDateStr = event.type == EventType.long ? event.endDate : event.date;
    final endDateTime = DateTime.parse('$endDateStr ${event.endTime}');

    final filteredCodes = event.qrCodes.where((code) {
      final isUsed = event.usedQRCodes[code] ?? false;
      final isExpired = !isUsed && now.isAfter(endDateTime);
      final isAvailable = !isUsed && !isExpired;
      final isShared = event.sharedQRCodes[code] ?? false;

      if (qrStatusFilter == 'Used' && !isUsed) return false;
      if (qrStatusFilter == 'Expired' && !isExpired) return false;
      if (qrStatusFilter == 'Available' && !isAvailable) return false;

      if (qrFilter == 'Shared' && !isShared) return false;
      if (qrFilter == 'Unshared' && isShared) return false;

      return true;
    }).toList();

    final totalPages = (filteredCodes.length / itemsPerPage).ceil();
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, filteredCodes.length);
    final pagedCodes = filteredCodes.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details & QR Codes'),
        actions: [
          ExportPdfButton(event: event,
            selectedQRCodes: selectedQRCodes.toList(),
          ),
          if (!selectionMode)
            IconButton(
              tooltip: useGrid ? 'Switch to List View' : 'Switch to Grid View',
              icon: Icon(useGrid ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => useGrid = !useGrid),
            ),
          if (!selectionMode)
            GlobalOptionsButton(
              context: context,
              currentScreen: 'event_detail',
              event: event,
              visibleOptions: const ['select', 'customize', 'share', 'delete','add'],
              onStartSelection: () {
                setState(() {
                  selectionMode = true;
                  initiatedFromShare = false;
                  initiatedFromDelete = false;
                  initiatedFromCustomize = false;
                });
              },
              onShareSelection: () {
                setState(() {
                  selectionMode = true;
                  initiatedFromShare = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select the QR codes you want to share.')),
                );
              },
              onCustomizeSave: (updatedEvent) {
                setState(() {
                  event = updatedEvent; });
              },
              onDeleteSelection: () {
                setState(() {
                  selectionMode = true;
                  initiatedFromDelete = true;
                });
              },
              onCustomizeSelect: () {
                setState(() {
                  initiatedFromCustomize = true;
                });
              },


              onAddQrCodes: _showAddQrDialog,
              selectedQrCodes: selectedQRCodes.toList(),
            ),

          if (selectionMode) ...[
            IconButton(
              icon: Icon(
                selectedQRCodes.length == event.qrCodes.length
                    ? Icons.remove_done
                    : Icons.select_all,
              ),
              tooltip: selectedQRCodes.length == event.qrCodes.length
                  ? 'Unselect All'
                  : 'Select All',
              onPressed: _toggleSelectAll,
            ),
            if (!initiatedFromShare && !initiatedFromDelete && !initiatedFromCustomize) ...[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelectedQRCodes,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareSelected,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _cancelSelection();
                  initiatedFromShare = false;
                  initiatedFromDelete = false;
                  initiatedFromCustomize = false;
                });
              },
            ),
          ]
        ],

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Détails à gauche
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📌 ${event.name}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("📅 ${event.date}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("🕒 ${event.startTime} - ${event.endTime}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          if (event.type == EventType.long && event.endDate != null)
                            Text("📅 End Date: ${event.endDate}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          if (event.description.isNotEmpty)
                            Text("📝 ${event.description}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("📍 Location: ${event.location}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("👤 Organizer: ${event.organizer}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("🔢 QR Codes: ${event.qrCodes.length}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text("🎟️ Ticket Style: ${event.selectedTicketStyle.name}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

                        ],
                      ),
                    ),

                    const SizedBox(width: 10),
                    if (event.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          event.image!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(thickness: 0.6, height: 10),
                const SizedBox(height: 10),

                // Filtres
                Row(
                  children: [
                    const Text("QR Shared: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    DropdownButton<String>(
                      value: qrFilter,
                      onChanged: (value) => setState(() => qrFilter = value!),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Shared', child: Text('Shared')),
                        DropdownMenuItem(value: 'Unshared', child: Text('Unshared')),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Text("QR Status: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    DropdownButton<String>(
                      value: qrStatusFilter,
                      onChanged: (value) => setState(() => qrStatusFilter = value!),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Available', child: Text('Available')),
                        DropdownMenuItem(value: 'Used', child: Text('Used')),
                        DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 4, thickness: 0.6),
          Expanded(
            child: filteredCodes.isEmpty ? const Center(child: Icon(Icons.qr_code_2_outlined, size: 80, color: Colors.grey,),)
                : Builder(
              builder: (_) {
                final builder = useGrid
                    ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: event.selectedTicketStyle == TicketStyle.minimal ? 0 : 10,
                  ),
                  itemCount: pagedCodes.length,
                  itemBuilder: (_, index) => _buildTicketItem(
                    pagedCodes[index],
                    index,
                    startIndex,
                    now,
                    endDateTime,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: pagedCodes.length,
                  itemBuilder: (_, index) => _buildTicketItem(
                    pagedCodes[index],
                    index,
                    startIndex,
                    now,
                    endDateTime,
                  ),
                );
                return builder;
              },
            ),
          ),

          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentPage > 1)
                      OutlinedButton(
                        onPressed: () => setState(() => currentPage--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(36, 32),
                          textStyle: const TextStyle(fontSize: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('←'),
                      ),
                    ...List.generate(totalPages, (index) {
                      final pageNumber = index + 1;
                      final isSelected = currentPage == pageNumber;
                      final shouldShow = (pageNumber == 1 || pageNumber == totalPages || (pageNumber >= currentPage - 1 && pageNumber <= currentPage + 1));
                      if (!shouldShow) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: OutlinedButton(
                          onPressed: () => setState(() => currentPage = pageNumber),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(36, 32),
                            textStyle: const TextStyle(fontSize: 13),
                            backgroundColor: isSelected ? Colors.blue : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            side: BorderSide(color: Colors.blue.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text('$pageNumber'),
                        ),
                      );
                    }),
                    if (currentPage < totalPages)
                      OutlinedButton(
                        onPressed: () => setState(() => currentPage++),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(36, 32),
                          textStyle: const TextStyle(fontSize: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('→'),
                      ),
                  ],
                ),
              ),
            )
        ],
      ),
      floatingActionButton: selectionMode && selectedQRCodes.isNotEmpty
          ? (initiatedFromDelete
          ? FloatingActionButton.extended(
        onPressed: _deleteSelectedQRCodes,
        icon: const Icon(Icons.delete),
        label: const Text('Delete selection'),
      )
          : initiatedFromShare
          ? FloatingActionButton.extended(
        onPressed: _shareSelected,
        icon: const Icon(Icons.share),
        label: const Text('Share selected'),
      )
          : initiatedFromCustomize
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomizePerforatedStyleScreen(
                event: event,
                targetQrCodes: selectedQRCodes.toList(),
                onSave: (updatedEvent) {
                  final provider = Provider.of<EventProvider>(context, listen: false);
                  final index = provider.events.indexWhere((e) => e.id == updatedEvent.id);
                  if (index != -1) {
                    provider.updateEvent(index, updatedEvent); // ✅ sauvegarde dans provider
                  }

                  setState(() {
                    event = updatedEvent;
                    _cancelSelection();
                  });
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.palette),
        label: const Text('Customize selected'),
      )
          : null)
          : null,
    );
  }

  Widget _buildTicketWidget(String qrCode, int number, {required bool isSelected}) {
    final style = event.selectedTicketStyle;
    final isUsed = event.usedQRCodes[qrCode] ?? false;
    final isExpired = !isUsed && DateTime.now().isAfter(
        DateTime.parse('${event.type == EventType.long ? event.endDate : event.date} ${event.endTime}'));
    final statusLabel = isUsed ? 'Used' : isExpired ? 'Expired' : 'Available';
    final isShared = event.sharedQRCodes[qrCode] ?? false;

    switch (style) {
      case TicketStyle.classic:
        return ClassicTicketCard(
          qrCode: qrCode,
          qrNumber: number,
          event: event,
          isSelected: isSelected,
          statusLabel: statusLabel,
          isShared: isShared,
        );
      case TicketStyle.centered:
        return CenteredTicketCard(
          qrCode: qrCode,
          qrNumber: number,
          event: event,
          isSelected: isSelected,
          statusLabel: statusLabel,
          isShared: isShared,
          isGrid: useGrid,
        );

      case TicketStyle.minimal:
        return MinimalTicketCard(
          qrCode: qrCode,
          qrNumber: number,
          event: event,
          isSelected: isSelected,
          statusLabel: statusLabel,
          isShared: isShared,
        );
      case TicketStyle.perforated:
        return PerforatedTicketCard(
          qrCode: qrCode,
          qrNumber: number,
          event: event,
          isSelected: isSelected,
          statusLabel: statusLabel,
          isShared: isShared,
          isGrid: useGrid,
        );
    }
  }

  Widget _buildTicketItem(String code, int index, int startIndex, DateTime now, DateTime endDateTime) {
    final isUsed = event.usedQRCodes[code] ?? false;
    final isExpired = !isUsed && now.isAfter(endDateTime);
    final isSelected = selectedQRCodes.contains(code);
    final isShared = event.sharedQRCodes[code] ?? false;

    List<Widget> badges = [];

    if (isUsed) {
      badges.add(_buildBadge("Used", Colors.red));
    } else if (isExpired) {
      badges.add(_buildBadge("Expired", Colors.orange));
    } else {
      badges.add(_buildBadge("Available", Colors.blue));
    }

    if (isShared) {
      badges.add(_buildBadge("Shared", Colors.purple));
    }

    final isCentered = event.selectedTicketStyle == TicketStyle.centered;

    final ticket = _buildTicketWidget(code, startIndex + index + 1, isSelected: isSelected);

    final isMinimal = event.selectedTicketStyle == TicketStyle.minimal;
// Badges en colonne, en haut à droite (seulement pour Centered + grille)
    final topRightBadges = Positioned(
      top: 6,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < badges.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            badges[i],
          ]
        ],
      ),
    );

// Badges en bas (autres styles ou list view)
    final bottomBadges = Padding(
      padding: EdgeInsets.only(
        top: useGrid ? (isMinimal ? 2 : 6) : 6,
        bottom: event.selectedTicketStyle == TicketStyle.perforated
            ? 2
            : useGrid
            ? (isMinimal ? 2 : 8)
            : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < badges.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            badges[i],
          ]
        ],
      ),
    );

// Affichage conditionnel
    final ticketContent = useGrid && isCentered
        ? Stack(
      children: [
        ticket,
        if (badges.isNotEmpty) topRightBadges,
      ],
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ticket,
        if (badges.isNotEmpty) bottomBadges,
      ],
    );

// Wrapper final
    return GestureDetector(
      onLongPress: () => setState(() {
        selectionMode = true;
        selectedQRCodes.add(code);
      }),
      onTap: () {
        if (selectionMode) {
          setState(() => isSelected ? selectedQRCodes.remove(code) : selectedQRCodes.add(code));
        } else {
          final isPerforated = event.selectedTicketStyle == TicketStyle.perforated;
          isPerforated
              ? _showPerforatedTicketOptions(code)
              : _showQRCodePreviewDialog(code);
        }
      },
      child: useGrid ? IntrinsicHeight(child: ticketContent) : ticketContent,
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  void _showQRCodePreviewDialog(String qrCode) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 400,
            minHeight: 150,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ticket Preview',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _buildTicketWidget(qrCode, event.qrCodes.indexOf(qrCode) + 1,
                  isSelected: false),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPerforatedTicketOptions(String qrCode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ticket Options'),
        content: const Text('What would you like to do with this ticket?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showQRCodePreviewDialog(qrCode);
            },
            child: const Text('👁️ View Ticket'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomizePerforatedStyleScreen(
                    event: event,
                    qrCode: qrCode,
                    onSave: (updated) {
                      final provider = Provider.of<EventProvider>(context, listen: false);
                      final index = provider.events.indexWhere((e) => e.id == updated.id);
                      if (index != -1) {
                        provider.updateEvent(index, updated);
                        setState(() => event = updated); // 🔄 refresh instantané
                      }
                    },
                  ),
                ),
              );
            },
            child: const Text('🎨 Customize Ticket'),
          ),
        ],
      ),
    );
  }
}
