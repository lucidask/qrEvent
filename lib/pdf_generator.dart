import 'dart:ui';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_event_app/ticket_style.dart';
import 'event.dart';

abstract class PdfGenerator {
  Future<void> generate(Event event, List<String> qrCodes);
  static PdfGenerator bracelet() => BraceletPdfGenerator();
}

class BraceletPdfGenerator implements PdfGenerator {
  @override
  Future<void> generate(Event event, List<String> qrCodes) async {
    final pdf = pw.Document();
    final braceletHeight = 80.0;
    final spacing = 8.0;

    final List<pw.Widget> bracelets = [];
    final Map<String, pw.ImageProvider> imageProviders = {};
    final Map<String, pw.ImageProvider> bgImageProviders = {};

    final classicBgColor = PdfColor.fromInt(
      (event.generalClassicSettings?.bgColor ?? const Color(0xFFFFFFFF)).value,
    );
    final classicTextColor = PdfColor.fromInt(
      (event.generalClassicSettings?.textColor ?? const Color(0xFF000000)).value,
    );
    final minimalBgColor = PdfColor.fromInt(
      (event.generalMinimalSettings?.bgColor ?? const Color(0xFFFFFFFF)).value,
    );
    final minimalTextColor = PdfColor.fromInt(
      (event.generalMinimalSettings?.textColor ?? const Color(0xFF000000)).value,
    );


    for (final qrCode in qrCodes) {
      final settings = event.customPerforatedSettings[qrCode];

      if (settings?.backgroundImage != null) {
        final file = settings!.backgroundImage!;
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          bgImageProviders[qrCode] = pw.MemoryImage(bytes);
        }
      }

      final shouldShowImage = settings?.showImage ?? event.perforatedShowImage;

      if (shouldShowImage && event.image != null) {
        final imageFile = event.image!;
        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();
          imageProviders[qrCode] = pw.MemoryImage(bytes);
        }
      }
    }

    for (int i = 0; i < qrCodes.length; i++) {
      final qrCode = qrCodes[i];
      final qrNumber = event.qrCodes.indexOf(qrCode) + 1;
      final settings = event.customPerforatedSettings[qrCode];
      final style = event.selectedTicketStyle;

      final bgColor = PdfColor.fromInt(
        (settings?.bgColor ?? event.perforatedBackgroundColor ?? const Color(0xFFFFFFFF)).value,
      );

      final textColor = PdfColor.fromInt(
        (settings?.textColor ?? event.perforatedTextColor ?? const Color(0xFFFFFFFF)).value,
      );

      final bracelet = switch (style) {
        TicketStyle.classic => pw.Container(
          height: braceletHeight,
          margin: pw.EdgeInsets.only(bottom: spacing),
          decoration: pw.BoxDecoration(
              color: classicBgColor, border: pw.Border.all(color: PdfColors.grey300)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(width: 8),
              pw.Container(
                width: 60,
                height: 60,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrCode,
                  width: 60,
                  height: 60,
                  backgroundColor: PdfColors.white,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(event.name, style: pw.TextStyle(fontSize: 10, color: classicTextColor)),
                  pw.Text("${event.date} - ${event.startTime}", style: pw.TextStyle(fontSize: 9, color: classicTextColor)),
                  pw.Text("Ticket #$qrNumber", style: pw.TextStyle(fontSize: 8, color: classicTextColor)),
                  pw.Text(event.organizer, style: pw.TextStyle(fontSize: 10, color: classicTextColor)),
                ],
              ),
              pw.SizedBox(width: 8),
            ],
          ),
        ),

        TicketStyle.minimal => pw.Container(
            height: braceletHeight,
            margin: pw.EdgeInsets.only(bottom: spacing),
            decoration: pw.BoxDecoration(
                color: minimalBgColor, border: pw.Border.all(color: PdfColors.grey300)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
              pw.Container(
              width: 60,
              height: 60,
              margin: pw.EdgeInsets.symmetric(horizontal: 8),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qrCode,
                width: 60,
                height: 60,
                  backgroundColor: PdfColors.white,
              ),
            ),
                pw.Text("Ticket #$qrNumber", style: pw.TextStyle(fontSize: 10, color: minimalTextColor)),
                pw.Text(event.name, style: pw.TextStyle(fontSize: 10, color: minimalTextColor)),
              ],
      ),
      ),

        TicketStyle.perforated => pw.Container(
          height: braceletHeight,
          margin: pw.EdgeInsets.only(bottom: spacing),
          child: pw.Stack(
            children: [
              // ✅ Background image (si défini dans settings)
              if (bgImageProviders.containsKey(qrCode))
                pw.Positioned.fill(
                  child: pw.Opacity(
                    opacity: settings?.imageOpacity ?? event.perforatedImageOpacity ?? 1.0,
                    child: pw.Image(bgImageProviders[qrCode]!, fit: pw.BoxFit.cover),
                  ),
                ),

              // ✅ Contenu avec rectangle et image à droite
              pw.Positioned.fill(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: bgColor,
                    border: pw.Border.all(color: PdfColors.grey700, width: 0.4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 65,
                        height: 65,
                        margin: pw.EdgeInsets.symmetric(horizontal: 8),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrCode,
                          width: 60,
                          height: 60,
                          backgroundColor: PdfColors.white
                        ),
                      ),
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(event.name, style: pw.TextStyle(fontSize: 10, color: textColor)),
                          pw.Text("${event.date} - ${event.startTime}", style: pw.TextStyle(fontSize: 9, color: textColor)),
                          pw.Text("Ticket #$qrNumber", style: pw.TextStyle(fontSize: 8, color: textColor)),
                          pw.Text(event.organizer, style: pw.TextStyle(fontSize: 10, color: textColor)),
                          if ((settings?.label?.isNotEmpty ?? false))
                            pw.Text(
                              settings!.label!,
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                        ],
                      ),
                      pw.SizedBox(width: 4),

                      // ✅ Image à droite si showImage est true et image chargée
                      if ((settings?.showImage ?? event.perforatedShowImage) && imageProviders.containsKey(qrCode))
                        pw.Container(
                          width: 60,
                          height: 60,
                          margin: pw.EdgeInsets.only(right: 8),
                          decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
                            border: pw.Border.all(color: PdfColors.grey700, width: 0.5),
                          ),
                          child: pw.Image(imageProviders[qrCode]!, fit: pw.BoxFit.cover),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        _ => pw.SizedBox(),
      };
      bracelets.add(bracelet);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: pw.EdgeInsets.all(20),
        build: (context) => [pw.Column(children: bracelets)],
      ),
    );

    final fileName = 'Bracelets_${event.name.replaceAll(' ', '_')}_${event.date}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }
}
