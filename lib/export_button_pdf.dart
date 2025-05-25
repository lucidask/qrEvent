import 'package:flutter/material.dart';
import 'package:qr_event_app/ticket_style.dart';
import 'event.dart';
import 'pdf_generator.dart';

class ExportPdfButton extends StatelessWidget {
  final Event event;
  final List<String> selectedQRCodes;

  const ExportPdfButton({
    super.key,
    required this.event,
    required this.selectedQRCodes,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _selectPdfFormat(context),
      icon: const Icon(Icons.print),
      label: const Text('Print'),
    );
  }

  Future<void> _selectPdfFormat(BuildContext context) async {
    if (selectedQRCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code selected.')),
      );
      return;
    }

    final format = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose a print format'),
        children: [
          // ✅ On cache "Bracelet" si le style est centered
          if (event.selectedTicketStyle != TicketStyle.centered)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'bracelet'),
              child: const Text('Bracelet format'),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'card'),
            child: const Text('Card format (coming soon)'),
          ),
        ],
      ),
    );

    if (format == 'bracelet') {
      try {
        await PdfGenerator.bracelet().generate(event, selectedQRCodes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during generation: $e')),
        );
      }
    }
  }
}
