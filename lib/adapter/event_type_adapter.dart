import 'package:hive/hive.dart';
import 'package:qr_event_app/event.dart';

class EventTypeAdapter extends TypeAdapter<EventType> {
  @override
  final int typeId = 1;

  @override
  EventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventType.short;
      case 1:
        return EventType.long;
      default:
        return EventType.short;
    }
  }

  @override
  void write(BinaryWriter writer, EventType obj) {
    switch (obj) {
      case EventType.short:
        writer.writeByte(0);
        break;
      case EventType.long:
        writer.writeByte(1);
        break;
    }
  }
}
