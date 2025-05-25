import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:qr_event_app/perforated_ticket_settings.dart';

class PerforatedTicketSettingsAdapter extends TypeAdapter<PerforatedTicketSettings> {
  @override
  final int typeId = 5;

  @override
  PerforatedTicketSettings read(BinaryReader reader) {
    return PerforatedTicketSettings(
      bgColor: Color(reader.readInt()),
      textColor: Color(reader.readInt()),
      label: reader.readString(),
      variant: reader.readInt(),
      showLocation: reader.readBool(),
      showOrganizer: reader.readBool(),
      showImage: reader.readBool(),
      backgroundImage: reader.readString().isNotEmpty
          ? File(reader.readString())
          : null,
      imageOpacity: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, PerforatedTicketSettings obj) {
    writer.writeInt(obj.bgColor.value);
    writer.writeInt(obj.textColor.value);
    writer.writeString(obj.label);
    writer.writeInt(obj.variant);
    writer.writeBool(obj.showLocation);
    writer.writeBool(obj.showOrganizer);
    writer.writeBool(obj.showImage);
    writer.writeString(obj.backgroundImage?.path ?? '');
    writer.writeDouble(obj.imageOpacity ?? 0.0);
  }
}
