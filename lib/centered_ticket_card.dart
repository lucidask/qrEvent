import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'event.dart';

class CenteredTicketCard extends StatelessWidget {
  final String qrCode;
  final int qrNumber;
  final Event event;
  final bool isSelected;
  final String statusLabel;
  final bool isShared;
  final bool isGrid;
  final bool isForShare;


  const CenteredTicketCard({
    super.key,
    required this.qrCode,
    required this.qrNumber,
    required this.event,
    required this.isSelected,
    required this.statusLabel,
    required this.isShared,
    this.isGrid = false,
    this.isForShare = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = event.generalCenteredSettings?.bgColor ?? Colors.white;
    final textColor = event.generalCenteredSettings?.textColor ?? Colors.black;


    final content = Container(
      margin: EdgeInsets.only(bottom: 0.1, right: isGrid ? 5 : 0),
      height: isGrid && !isForShare ? 220 : null,
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal.shade50 : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: qrCode,
            size: isForShare ? 120 : 70,
            backgroundColor: Colors.white, // 👈 arrière-plan blanc
          ),
          const SizedBox(height: 8),
          Text("🎟️ Ticket #$qrNumber", style:  TextStyle( color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(event.name, style: TextStyle(color: textColor, fontSize: 14), overflow: TextOverflow.ellipsis),
          if (!isGrid || isForShare) ...[
            Text("${event.date} ${event.startTime}", style: TextStyle(color: textColor, fontSize: 13)),
            Text("📍 ${event.location}", style: TextStyle(color: textColor, fontSize: 13)),
            Text("👤 ${event.organizer}", style: TextStyle(color: textColor, fontSize: 13)),
          ],
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
              child: event.image != null
                  ? Image.file(event.image!,
                  fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          ),
        ],
      ),
    );

    return isForShare
        ? Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: content,
      ),
    )
        : content;

  }
}

