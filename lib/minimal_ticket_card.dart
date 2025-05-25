import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'event.dart';

class MinimalTicketCard extends StatelessWidget {
  final String qrCode;
  final int qrNumber;
  final Event event;
  final bool isSelected;
  final String statusLabel;
  final bool isShared;
  final bool isGrid;
  final bool isForShare;

  const MinimalTicketCard({
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
    final bgColor = event.generalMinimalSettings?.bgColor ?? Colors.white;
    final textColor = event.generalMinimalSettings?.textColor ?? Colors.black;


    return Container(
      constraints: isForShare
          ? const BoxConstraints(minHeight: 80, maxWidth: 170)
          : const BoxConstraints(),
      height: isForShare ? 70 : 70,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade100 : bgColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(data: qrCode, size: 60, backgroundColor: Colors.white,),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🎟️ Ticket #$qrNumber", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(event.name, style: TextStyle(color: textColor, fontSize: 13), overflow: TextOverflow.ellipsis,
                ),
                Text("${event.date} ${event.startTime}", style: TextStyle(color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
