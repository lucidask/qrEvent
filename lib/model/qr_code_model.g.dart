// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QRCodeAdapter extends TypeAdapter<QRCode> {
  @override
  final int typeId = 3;

  @override
  QRCode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QRCode(
      code: fields[0] as String,
      status: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QRCode obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QRCodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
