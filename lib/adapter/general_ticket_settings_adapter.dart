import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:qr_event_app/general_ticket_settings.dart';

class GeneralTicketSettingsAdapter extends TypeAdapter<GeneralTicketSettings> {
  @override
  final int typeId = 4;

  @override
  GeneralTicketSettings read(BinaryReader reader) {
    return GeneralTicketSettings(
      bgColor: Color(reader.readInt()),
      textColor: Color(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, GeneralTicketSettings obj) {
    writer.writeInt(obj.bgColor.value);
    writer.writeInt(obj.textColor.value);
  }
}
