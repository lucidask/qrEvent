import 'package:flutter/material.dart';
import 'event.dart';

enum TicketStyle { classic, centered, perforated, minimal }

Future<TicketStyle?> showTicketStyleSelector(BuildContext context, TicketStyle currentStyle) async {
  return showModalBottomSheet<TicketStyle>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Choisissez un style de ticket", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _buildStyleTile(context, TicketStyle.classic, currentStyle, "🅰️ Classique"),
        _buildStyleTile(context, TicketStyle.centered, currentStyle, "🅱️ Centré"),
        _buildStyleTile(context, TicketStyle.perforated, currentStyle, "🆎 Perforé"),
        _buildStyleTile(context, TicketStyle.minimal, currentStyle, "🆑 Minimaliste"),
        const SizedBox(height: 10),
      ],
    ),
  );
}

ListTile _buildStyleTile(BuildContext context, TicketStyle style, TicketStyle current, String label) {
  return ListTile(
    leading: Icon(style == current ? Icons.radio_button_checked : Icons.radio_button_off),
    title: Text(label),
    onTap: () => Navigator.pop(context, style),
  );
}
