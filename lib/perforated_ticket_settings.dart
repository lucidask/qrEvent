import 'dart:io';
import 'dart:ui';

class PerforatedTicketSettings {
  final Color bgColor;
  final Color textColor;
  final String label;
  final int variant;
  final bool showLocation;
  final bool showOrganizer;
  final bool showImage;
  final File? backgroundImage;
  final double? imageOpacity;


  const PerforatedTicketSettings({
    required this.bgColor,
    required this.textColor,
    required this.label,
    required this.variant,
    required this.showLocation,
    required this.showOrganizer,
    required this.showImage,
    this.backgroundImage,
    this.imageOpacity,
  });

  // Conversion vers Hive
  Map<String, dynamic> toHiveMap() {
    return {
      'bgColor': bgColor.value,
      'textColor': textColor.value,
      'label': label,
      'variant': variant,
      'showLocation': showLocation,
      'showOrganizer': showOrganizer,
      'showImage': showImage,
      'backgroundImagePath': backgroundImage?.path,
      'imageOpacity': imageOpacity,
    };
  }

  // Conversion depuis Hive
  static PerforatedTicketSettings fromHiveMap(Map<String, dynamic> map) {
    return PerforatedTicketSettings(
      bgColor: Color(map['bgColor']),
      textColor: Color(map['textColor']),
      label: map['label'],
      variant: map['variant'],
      showLocation: map['showLocation'],
      showOrganizer: map['showOrganizer'],
      showImage: map['showImage'],
      backgroundImage: map['backgroundImagePath'] != null
          ? File(map['backgroundImagePath'])
          : null,
      imageOpacity: map['imageOpacity'],
    );
  }


  PerforatedTicketSettings copyWith({
    Color? bgColor,
    Color? textColor,
    String? label,
    int? variant,
    bool? showLocation,
    bool? showOrganizer,
    bool? showImage,
    File? backgroundImage,
    double? imageOpacity,
  }) {
    return PerforatedTicketSettings(
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      label: label ?? this.label,
      variant: variant ?? this.variant,
      showLocation: showLocation ?? this.showLocation,
      showOrganizer: showOrganizer ?? this.showOrganizer,
      showImage: showImage ?? this.showImage,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      imageOpacity: imageOpacity ?? this.imageOpacity,
    );
  }
}
