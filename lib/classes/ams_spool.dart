import 'package:bamscan/classes/spool.dart';

class AmsSpool {
  final int id;
  final int spoolId;
  final int printerId;
  final String printerName;
  final int amsId;
  final int trayId;
  final String? fingerprintColor;
  final String? fingerprintType;
  final DateTime createdAt;
  final Spool spool;
  final bool configured;
  final String? amsLabel;

  const AmsSpool({
    required this.id,
    required this.spoolId,
    required this.printerId,
    required this.printerName,
    required this.amsId,
    required this.trayId,
    this.fingerprintColor,
    this.fingerprintType,
    required this.createdAt,
    required this.spool,
    required this.configured,
    this.amsLabel,
  });

  factory AmsSpool.fromJson(Map<String, dynamic> json) {
    try {
      return AmsSpool(
        id: json['id'] as int,
        spoolId: json['spool_id'] as int,
        printerId: json['printer_id'] as int,
        printerName: json['printer_name'] as String,
        amsId: json['ams_id'] as int,
        trayId: json['tray_id'] as int,
        fingerprintColor: json['fingerprint_color'] as String?,
        fingerprintType: json['fingerprint_type'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        spool: Spool.fromJson(json['spool'] as Map<String, dynamic>),
        configured: json['configured'] as bool,
        amsLabel: json['ams_label'] as String?,
      );
    } on FormatException {
      rethrow;
    } on TypeError {
      throw FormatException('Invalid type in AMS spool JSON data');
    } catch (e) {
      throw FormatException('Failed to parse AMS spool JSON: $e');
    }
  }
}
