import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'event.dart';

class PerforatedTicketCard extends StatelessWidget {
  final String qrCode;
  final int qrNumber;
  final Event event;
  final bool isSelected;
  final bool isGrid;
  final String statusLabel;
  final bool isShared;
  final bool isForShare;
  final bool hasImportantLabel;

  const PerforatedTicketCard({
    super.key,
    required this.qrCode,
    required this.qrNumber,
    required this.event,
    required this.isSelected,
    required this.statusLabel,
    required this.isShared,
    this.isGrid = false,
    this.isForShare = false,
    this.hasImportantLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = event.customPerforatedSettings[qrCode];
    final bgColor = settings?.bgColor ?? event.perforatedBackgroundColor;
    final textColor = settings?.textColor ?? event.perforatedTextColor;
    final label = settings?.label ?? event.perforatedImportantLabel;
    final showLocation = settings?.showLocation ?? event.perforatedShowLocation;
    final showOrganizer = settings?.showOrganizer ?? event.perforatedShowOrganizer;
    final showImage = settings?.showImage ?? event.perforatedShowImage;
    final int variant = settings?.variant ?? event.perforatedVariant;
    final bgImage = settings?.backgroundImage ?? event.perforatedBackgroundImage;
    final imageOpacity = settings?.imageOpacity ?? event.perforatedImageOpacity ?? 0.0;

    return Container(
      constraints: isForShare
          ? const BoxConstraints(minHeight: 100, maxWidth: 350)
          : const BoxConstraints(),
      height: switch (variant) {
        2 => isForShare ? 240 : 186,
        3 => isForShare ? 240 : 186,
        _ => isGrid
            ? (hasImportantLabel ? 130 : 125)
            : (hasImportantLabel ? 140 : 135),
      },
      decoration: BoxDecoration(
        color: bgImage == null
            ? (isSelected ? Colors.orange.shade50 : bgColor)
            : null,
        image: bgImage != null
            ? DecorationImage(
          image: FileImage(bgImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(1 - imageOpacity),
            BlendMode.dstATop,
          ),
        )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(10),
      child: _buildVariantContent(variant, textColor, label, showLocation, showOrganizer, showImage),
    );
  }

  Widget _buildPerforatedDivider({Axis axis = Axis.vertical}) {
    return axis == Axis.vertical
        ? Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.black26, width: 1),
        ),
      ),
    )
        : Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black26, width: 1),
        ),
      ),
    );
  }

  Widget _buildVariantContent(int variant, Color textColor, String label, bool showLocation, bool showOrganizer, bool showImage) {
    switch (variant) {
      case 2:
        return _buildVariant2Layout(textColor, label, showLocation, showOrganizer, showImage);
      case 3:
        return _buildVariant3Layout(textColor, label, showLocation, showOrganizer, showImage);
      case 4:
        return _buildVariant4Layout(textColor, label, showLocation, showOrganizer, showImage);
      default:
        return _buildVariant1Layout(textColor, label, showLocation, showOrganizer, showImage);
    }
  }

  Widget _buildImageBox({double size = 50}) {
    return Container(
      width: size,
      height: size,
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
    );
  }

  Widget _buildVariant1Layout(Color textColor, String label, bool showLocation, bool showOrganizer, bool showImage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: isForShare ? 105 : 55.7,
            height: isForShare ? 125 : 55.7,
            color: Colors.white,
            child: Center(
              child: QrImageView(
                data: qrCode,
                size: isForShare ? 105 : 55.7,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        _buildPerforatedDivider(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    maxLines: hasImportantLabel ? 2 : 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text("🎟️ Ticket #$qrNumber", style: TextStyle(fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
              Text("📌 ${event.name}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
              Text("📌 ${event.date} ${event.startTime}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
              if (showLocation)
                Text("📍 ${event.location}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
              if (showOrganizer)
                Text("👤 ${event.organizer}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        _buildPerforatedDivider(),
        const SizedBox(width: 12),
        if (showImage) _buildImageBox() else const SizedBox.shrink(),

      ],
    );
  }

  Widget _buildVariant2Layout(Color textColor, String label, bool showLocation, bool showOrganizer, bool showImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrCode,
              size: isForShare ? 105 : 53,
              backgroundColor: Colors.white,
            ),

            const SizedBox(width: 8),

            // ✅ Trait vertical perforé
            Container(
              width: 1,
              height: isForShare ? 50 : 40,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: Colors.black26,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            _buildImageBox(size: isForShare ? 105 : 53),
          ],
        ),
        _buildPerforatedDivider(axis: Axis.horizontal),
        const SizedBox(height: 4),
        if (label.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Text("🎟️ Ticket #$qrNumber", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
        Text("📌 ${event.name}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
        Text("📅 ${event.date} ${event.startTime}", style: TextStyle(fontSize: 12, color: textColor)),
        if (showLocation)
          Text("📍 ${event.location}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
        if (showOrganizer)
          Text("👤 ${event.organizer}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildVariant3Layout(Color textColor, String label, bool showLocation, bool showOrganizer, bool showImage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // QR en haut
        QrImageView(
          data: qrCode,
          size: isForShare ? 100 : 50,
          backgroundColor: Colors.white,
        ),

        // Trait horizontal centré avec largeur réduite
        Container(
          width: 160,
          height: 1,
          color: Colors.black26,
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),

        // Image - Trait - Texte alignés
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageBox(size: isForShare ? 100 : 50),

            const SizedBox(width: 8),

            Container(
              width: 1,
              height: 80,
              color: Colors.black26,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),

            // Texte centré
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (label.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text("🎟️ Ticket #$qrNumber", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
                  Text("📌 ${event.name}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
                  Text("📅 ${event.date} ${event.startTime}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
                  if (showLocation)
                    Text("📍 ${event.location}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
                  if (showOrganizer)
                    Text("👤 ${event.organizer}", style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildVariant4Layout(Color textColor, String label, bool showLocation, bool showOrganizer, bool showImage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Image
        _buildImageBox(size: isForShare ? 105 : 55.7),

        // ✅ Trait perforé
        _buildPerforatedDivider(),

        // ✅ QR
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: isForShare ? 105 : 55.7,
            height: isForShare ? 125 : 55.7,
            color: Colors.white,
            child: Center(
              child: QrImageView(
                data: qrCode,
                size: isForShare ? 105 : 55.7,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),

        // ✅ Trait perforé
        _buildPerforatedDivider(),

        // ✅ Texte
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    maxLines: hasImportantLabel ? 2 : 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text("🎟️ Ticket #$qrNumber", style: TextStyle(fontWeight: FontWeight.bold, color: textColor), overflow: TextOverflow.ellipsis),
              Text("📌 ${event.name}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
              Text("📅 ${event.date} ${event.startTime}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
              if (showLocation)
                Text("📍 ${event.location}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
              if (showOrganizer)
                Text("👤 ${event.organizer}", style: TextStyle(color: textColor), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

}
