import 'dart:io';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:qr_event_app/event.dart';
import 'package:qr_event_app/ticket_style.dart';
part 'event_hive_model.g.dart';


@HiveType(typeId: 0)
class EventHiveModel extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int typeIndex;

  @HiveField(3)
  String date;

  @HiveField(4)
  String startTime;

  @HiveField(5)
  String endTime;

  @HiveField(6)
  String? endDate;

  @HiveField(7)
  String description;

  @HiveField(8)
  int numberOfQrCodes;

  @HiveField(9)
  String location;

  @HiveField(10)
  String organizer;

  @HiveField(11)
  String? imagePath;

  @HiveField(12)
  List<String> qrCodes;

  @HiveField(13)
  Map<String, bool> usedQRCodes;

  @HiveField(14)
  Map<String, bool> sharedQRCodes;

  @HiveField(15)
  int ticketStyleIndex;

  @HiveField(16)
  int perforatedVariant;

  @HiveField(17)
  int perforatedBackgroundColorValue;

  @HiveField(18)
  int perforatedTextColorValue;

  @HiveField(19)
  bool perforatedShowLocation;

  @HiveField(20)
  bool perforatedShowOrganizer;

  @HiveField(21)
  bool perforatedShowImage;

  @HiveField(22)
  String perforatedImportantLabel;

  @HiveField(23)
  double? perforatedImageOpacity;

  @HiveField(24)
  String? perforatedBackgroundImagePath;

  @HiveField(25)
  Map<String, dynamic> customPerforatedSettings;

  @HiveField(26)
  dynamic generalClassicSettings;

  @HiveField(27)
  dynamic generalCenteredSettings;

  @HiveField(28)
  dynamic generalMinimalSettings;

  EventHiveModel({
    required this.id,
    required this.name,
    required this.typeIndex,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.endDate,
    required this.description,
    required this.numberOfQrCodes,
    required this.location,
    required this.organizer,
    this.imagePath,
    required this.qrCodes,
    required this.usedQRCodes,
    required this.sharedQRCodes,
    required this.ticketStyleIndex,
    required this.perforatedVariant,
    required this.perforatedBackgroundColorValue,
    required this.perforatedTextColorValue,
    required this.perforatedShowLocation,
    required this.perforatedShowOrganizer,
    required this.perforatedShowImage,
    required this.perforatedImportantLabel,
    this.perforatedImageOpacity,
    this.perforatedBackgroundImagePath,
    required this.customPerforatedSettings,
    this.generalClassicSettings,
    this.generalCenteredSettings,
    this.generalMinimalSettings,
  });
}

// 🔥 Les extensions : conversion EventHiveModel <-> Event
extension EventHiveConversion on EventHiveModel {
  Event toEvent() {
    return Event(
      id: id,
      name: name,
      type: EventType.values[typeIndex],
      date: date,
      startTime: startTime,
      endTime: endTime,
      endDate: endDate,
      description: description,
      numberOfQrCodes: numberOfQrCodes,
      location: location,
      organizer: organizer,
      image: imagePath != null && imagePath!.isNotEmpty ? File(imagePath!) : null,
      qrCodes: qrCodes,
      selectedTicketStyle: TicketStyle.values[ticketStyleIndex],
      perforatedVariant: perforatedVariant,
      perforatedBackgroundColor: Color(perforatedBackgroundColorValue),
      perforatedTextColor: Color(perforatedTextColorValue),
      perforatedShowLocation: perforatedShowLocation,
      perforatedShowOrganizer: perforatedShowOrganizer,
      perforatedShowImage: perforatedShowImage,
      perforatedImportantLabel: perforatedImportantLabel,
      perforatedBackgroundImage: perforatedBackgroundImagePath != null && perforatedBackgroundImagePath!.isNotEmpty
          ? File(perforatedBackgroundImagePath!)
          : null,
      perforatedImageOpacity: perforatedImageOpacity,
      customPerforatedSettings: {}, // À gérer plus tard
      generalClassicSettings: generalClassicSettings,
      generalCenteredSettings: generalCenteredSettings,
      generalMinimalSettings: generalMinimalSettings,
    );
  }
}

extension EventConversion on Event {
  EventHiveModel toHiveModel() {
    return EventHiveModel(
      id: id,
      name: name,
      typeIndex: type.index,
      date: date,
      startTime: startTime,
      endTime: endTime,
      endDate: endDate,
      description: description,
      numberOfQrCodes: numberOfQrCodes,
      location: location,
      organizer: organizer,
      imagePath: image?.path,
      qrCodes: qrCodes,
      usedQRCodes: usedQRCodes,
      sharedQRCodes: sharedQRCodes,
      ticketStyleIndex: selectedTicketStyle.index,
      perforatedVariant: perforatedVariant,
      perforatedBackgroundColorValue: perforatedBackgroundColor.value,
      perforatedTextColorValue: perforatedTextColor.value,
      perforatedShowLocation: perforatedShowLocation,
      perforatedShowOrganizer: perforatedShowOrganizer,
      perforatedShowImage: perforatedShowImage,
      perforatedImportantLabel: perforatedImportantLabel,
      perforatedImageOpacity: perforatedImageOpacity,
      perforatedBackgroundImagePath: perforatedBackgroundImage?.path,
      customPerforatedSettings: {}, // À gérer plus tard
      generalClassicSettings: generalClassicSettings,
      generalCenteredSettings: generalCenteredSettings,
      generalMinimalSettings: generalMinimalSettings,
    );
  }

}
