import 'package:flutter/material.dart';

class GeneralTicketSettings {
  final Color bgColor;
  final Color textColor;

  GeneralTicketSettings({
    required this.bgColor,
    required this.textColor,
  });

  // Méthodes de conversion
  Map<String, dynamic> toHiveMap() {
    return {
      'bgColor': bgColor.value,
      'textColor': textColor.value,
    };
  }

  static GeneralTicketSettings fromHiveMap(Map<String, dynamic> map) {
    return GeneralTicketSettings(
      bgColor: Color(map['bgColor']),
      textColor: Color(map['textColor']),
    );
  }
}
