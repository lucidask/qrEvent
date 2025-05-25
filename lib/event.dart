import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_event_app/perforated_ticket_settings.dart';
import 'package:uuid/uuid.dart';
import 'general_ticket_settings.dart';
import 'ticket_style.dart';

enum EventType { short, long }

class Event {
  final String id;
  final String name;
  final EventType type;
  final String date;
  final String startTime;
  final String endTime;
  final String? endDate;
  final String description;
  final int numberOfQrCodes;
  final String location;
  final String organizer;
  final File? image;
  final List<String> qrCodes;
  final Map<String, bool> usedQRCodes;
  final Map<String, bool> sharedQRCodes;
  final TicketStyle selectedTicketStyle;

  final int perforatedVariant;
  final Color perforatedBackgroundColor;
  final Color perforatedTextColor;
  final bool perforatedShowLocation;
  final bool perforatedShowOrganizer;
  final bool perforatedShowImage;
  final String perforatedImportantLabel;
  final double? perforatedImageOpacity;
  File? perforatedBackgroundImage;
  final Map<String, PerforatedTicketSettings> customPerforatedSettings;

  final GeneralTicketSettings? generalClassicSettings;
  final GeneralTicketSettings? generalCenteredSettings;
  final GeneralTicketSettings? generalMinimalSettings;


  Event({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.endDate,
    required this.description,
    required this.numberOfQrCodes,
    required this.location,
    required this.organizer,
    this.image,
    this.selectedTicketStyle = TicketStyle.classic,
    this.perforatedVariant = 1,
    this.perforatedBackgroundColor = Colors.white,
    this.perforatedTextColor = Colors.black,
    this.perforatedShowLocation = true,
    this.perforatedShowOrganizer = true,
    this.perforatedShowImage = true,
    this.perforatedImportantLabel = '',
    this.customPerforatedSettings = const {},
    this.perforatedBackgroundImage,
    this.perforatedImageOpacity,
    this.generalClassicSettings,
    this.generalCenteredSettings,
    this.generalMinimalSettings,
    List<String>? qrCodes,
  })  : qrCodes = qrCodes ?? List.generate(numberOfQrCodes, (_) => const Uuid().v4()),
        usedQRCodes = {
          for (var code in qrCodes ?? List.generate(numberOfQrCodes, (_) => const Uuid().v4()))
            code: false,
        },
        sharedQRCodes = {
          for (var code in qrCodes ?? List.generate(numberOfQrCodes, (_) => const Uuid().v4()))
            code: false,
        };

  Event copyWith({
    String? id,
    String? name,
    EventType? type,
    String? date,
    String? startTime,
    String? endTime,
    String? endDate,
    String? description,
    int? numberOfQrCodes,
    String? location,
    String? organizer,
    File? image,
    List<String>? qrCodes,
    Map<String, bool>? usedQRCodes,
    Map<String, bool>? sharedQRCodes,
    TicketStyle? selectedTicketStyle,
    int? perforatedVariant,
    Color? perforatedBackgroundColor,
    Color? perforatedTextColor,
    bool? perforatedShowLocation,
    bool? perforatedShowOrganizer,
    bool? perforatedShowImage,
    String? perforatedImportantLabel,
    Map<String, PerforatedTicketSettings>? customPerforatedSettings,
    File? perforatedBackgroundImage,
    double? perforatedImageOpacity,

    GeneralTicketSettings? generalClassicSettings,
    GeneralTicketSettings? generalCenteredSettings,
    GeneralTicketSettings? generalMinimalSettings,


  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      numberOfQrCodes: numberOfQrCodes ?? this.numberOfQrCodes,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      image: image ?? this.image,
      selectedTicketStyle: selectedTicketStyle ?? this.selectedTicketStyle,
      perforatedVariant: perforatedVariant ?? this.perforatedVariant,
      perforatedBackgroundColor: perforatedBackgroundColor ?? this.perforatedBackgroundColor,
      perforatedTextColor: perforatedTextColor ?? this.perforatedTextColor,
      perforatedShowLocation: perforatedShowLocation ?? this.perforatedShowLocation,
      perforatedShowOrganizer: perforatedShowOrganizer ?? this.perforatedShowOrganizer,
      perforatedShowImage: perforatedShowImage ?? this.perforatedShowImage,
      perforatedImportantLabel: perforatedImportantLabel ?? this.perforatedImportantLabel,
      customPerforatedSettings: customPerforatedSettings ?? this.customPerforatedSettings,
      perforatedBackgroundImage: perforatedBackgroundImage ?? this.perforatedBackgroundImage,
      qrCodes: qrCodes ?? this.qrCodes,
      perforatedImageOpacity: perforatedImageOpacity ?? this.perforatedImageOpacity,
      generalClassicSettings: generalClassicSettings ?? this.generalClassicSettings,
      generalCenteredSettings: generalCenteredSettings ?? this.generalCenteredSettings,
      generalMinimalSettings: generalMinimalSettings ?? this.generalMinimalSettings,


    );
  }
}
