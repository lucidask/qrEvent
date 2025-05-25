import 'package:hive/hive.dart';

part 'qr_code_model.g.dart';

@HiveType(typeId: 3)
class QRCode {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String status;

  QRCode({required this.code, required this.status});
}
