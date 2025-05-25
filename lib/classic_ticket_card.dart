import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'event.dart';

class ClassicTicketCard extends StatelessWidget {
  final String qrCode;
  final int qrNumber;
  final Event event;
  final bool isSelected;
  final String statusLabel;
  final bool isShared;
  final bool isForShare;

  const ClassicTicketCard({
    super.key,
    required this.qrCode,
    required this.qrNumber,
    required this.event,
    required this.isSelected,
    required this.statusLabel,
    required this.isShared,
    this.isForShare = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = event.generalClassicSettings?.bgColor ?? Colors.white;
    final textColor = event.generalClassicSettings?.textColor ?? Colors.black;

    return Container(
      constraints: isForShare
          ? const BoxConstraints(minHeight: 100, maxWidth: 260)
          : const BoxConstraints(),
      height: isForShare ? 105 : 140,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(
            data: qrCode,
            size: 60,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🎟️ Ticket #$qrNumber", style: TextStyle(color :textColor, fontWeight: FontWeight.bold)),
                Text("📌 ${event.name}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
                Text("📌 ${event.date} ${event.startTime}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
                Text("📍 ${event.location}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
                Text("👤 ${event.organizer}", overflow: TextOverflow.ellipsis,  style: TextStyle(color: textColor),),
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
              child: event.image != null
                  ? Image.file(event.image!, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

}
