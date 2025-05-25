// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventHiveModelAdapter extends TypeAdapter<EventHiveModel> {
  @override
  final int typeId = 0;

  @override
  EventHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      typeIndex: fields[2] as int,
      date: fields[3] as String,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      endDate: fields[6] as String?,
      description: fields[7] as String,
      numberOfQrCodes: fields[8] as int,
      location: fields[9] as String,
      organizer: fields[10] as String,
      imagePath: fields[11] as String?,
      qrCodes: (fields[12] as List).cast<String>(),
      usedQRCodes: (fields[13] as Map).cast<String, bool>(),
      sharedQRCodes: (fields[14] as Map).cast<String, bool>(),
      ticketStyleIndex: fields[15] as int,
      perforatedVariant: fields[16] as int,
      perforatedBackgroundColorValue: fields[17] as int,
      perforatedTextColorValue: fields[18] as int,
      perforatedShowLocation: fields[19] as bool,
      perforatedShowOrganizer: fields[20] as bool,
      perforatedShowImage: fields[21] as bool,
      perforatedImportantLabel: fields[22] as String,
      perforatedImageOpacity: fields[23] as double?,
      perforatedBackgroundImagePath: fields[24] as String?,
      customPerforatedSettings: (fields[25] as Map).cast<String, dynamic>(),
      generalClassicSettings: fields[26] as dynamic,
      generalCenteredSettings: fields[27] as dynamic,
      generalMinimalSettings: fields[28] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, EventHiveModel obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.numberOfQrCodes)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.organizer)
      ..writeByte(11)
      ..write(obj.imagePath)
      ..writeByte(12)
      ..write(obj.qrCodes)
      ..writeByte(13)
      ..write(obj.usedQRCodes)
      ..writeByte(14)
      ..write(obj.sharedQRCodes)
      ..writeByte(15)
      ..write(obj.ticketStyleIndex)
      ..writeByte(16)
      ..write(obj.perforatedVariant)
      ..writeByte(17)
      ..write(obj.perforatedBackgroundColorValue)
      ..writeByte(18)
      ..write(obj.perforatedTextColorValue)
      ..writeByte(19)
      ..write(obj.perforatedShowLocation)
      ..writeByte(20)
      ..write(obj.perforatedShowOrganizer)
      ..writeByte(21)
      ..write(obj.perforatedShowImage)
      ..writeByte(22)
      ..write(obj.perforatedImportantLabel)
      ..writeByte(23)
      ..write(obj.perforatedImageOpacity)
      ..writeByte(24)
      ..write(obj.perforatedBackgroundImagePath)
      ..writeByte(25)
      ..write(obj.customPerforatedSettings)
      ..writeByte(26)
      ..write(obj.generalClassicSettings)
      ..writeByte(27)
      ..write(obj.generalCenteredSettings)
      ..writeByte(28)
      ..write(obj.generalMinimalSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
