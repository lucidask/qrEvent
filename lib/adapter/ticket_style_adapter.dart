import 'package:hive/hive.dart';
import 'package:qr_event_app/ticket_style.dart';

class TicketStyleAdapter extends TypeAdapter<TicketStyle> {
  @override
  final int typeId = 2;

  @override
  TicketStyle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TicketStyle.classic;
      case 1:
        return TicketStyle.centered;
      case 2:
        return TicketStyle.minimal;
      case 3:
        return TicketStyle.perforated;
      default:
        return TicketStyle.classic;
    }
  }

  @override
  void write(BinaryWriter writer, TicketStyle obj) {
    switch (obj) {
      case TicketStyle.classic:
        writer.writeByte(0);
        break;
      case TicketStyle.centered:
        writer.writeByte(1);
        break;
      case TicketStyle.minimal:
        writer.writeByte(2);
        break;
      case TicketStyle.perforated:
        writer.writeByte(3);
        break;
    }
  }
}
