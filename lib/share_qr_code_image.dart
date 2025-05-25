import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_event_app/minimal_ticket_card.dart';
import 'package:qr_event_app/perforated_ticket_card.dart';
import 'package:qr_event_app/ticket_style.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'centered_ticket_card.dart';
import 'event.dart';
import 'classic_ticket_card.dart';

class QRShareHelper {
  static Future<void> shareMultipleQRCodes(
      BuildContext context, {
        required List<String> qrDataList,
        required Event event,
        String prefix = 'qr_code',
      }) async {
    final imageFiles = <XFile>[];
    final tempDir = await getTemporaryDirectory();

    for (final qr in qrDataList) {
      final indexInEvent = event.qrCodes.indexOf(qr) + 1;
      final isUsed = event.usedQRCodes[qr] ?? false;
      final isExpired = !isUsed && DateTime.now().isAfter(
          DateTime.parse('${event.type == EventType.long ? event.endDate : event.date} ${event.endTime}')
      );
      final statusLabel = isUsed ? 'Used' : isExpired ? 'Expired' : 'Available';
      final isShared = event.sharedQRCodes[qr] ?? false;

      final Widget ticketWidget;

      switch (event.selectedTicketStyle) {
        case TicketStyle.centered:
          ticketWidget = CenteredTicketCard(
            qrCode: qr,
            qrNumber: indexInEvent,
            event: event,
            isSelected: false,
            statusLabel: statusLabel,
            isShared: isShared,
            isGrid: false,
            isForShare: true,
          );
          break;
        case TicketStyle.minimal:
          ticketWidget = MinimalTicketCard(
            qrCode: qr,
            qrNumber: indexInEvent,
            event: event,
            isSelected: false,
            statusLabel: statusLabel,
            isShared: isShared,
            isGrid: false,
            isForShare: true,
          );
          break;
        case TicketStyle.perforated:
          ticketWidget = PerforatedTicketCard(
            qrCode: qr,
            qrNumber: indexInEvent,
            event: event,
            isSelected: false,
            statusLabel: statusLabel,
            isShared: isShared,
            isGrid: false,
            isForShare: true,
          );
          break;
        case TicketStyle.classic:
          ticketWidget = ClassicTicketCard(
            qrCode: qr,
            qrNumber: indexInEvent,
            event: event,
            isSelected: false,
            statusLabel: statusLabel,
            isShared: isShared,
            isForShare: true,
          );
          break;
      }


      final ticketImage = await _renderToImage(context, ticketWidget);
      if (ticketImage != null) {
        final file = File('${tempDir.path}/$prefix-$indexInEvent.png');
        await file.writeAsBytes(ticketImage);
        imageFiles.add(XFile(file.path));

        event.sharedQRCodes[qr] = true;
      }
    }

    if (imageFiles.isNotEmpty) {
      await Share.shareXFiles(imageFiles, text: '🎟️ QR Tickets for ${event.name}');
    }
  }

  static Future<Uint8List?> _renderToImage(BuildContext context, Widget widget) async {
    final repaintKey = GlobalKey();
    final renderWidget = RepaintBoundary(
      key: repaintKey,
      child: Material(
        type: MaterialType.transparency,
        child: widget,
      ),
    );

    final overlay = OverlayEntry(builder: (_) => Center(child: renderWidget));
    Overlay.of(context).insert(overlay);

    await Future.delayed(const Duration(milliseconds: 300));

    final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary?.toImage(pixelRatio: 3.0);
    final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);

    overlay.remove();

    return byteData?.buffer.asUint8List();
  }
}
