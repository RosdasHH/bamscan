import 'package:bamscan/classes/printer_status.dart';

class Printer {
  final String name;
  final String serialNumber;
  final String ipAddress;
  final String accessCode;
  final String model;
  final String? location;
  final bool autoArchive;
  final String? externalCameraUrl;
  final String? externalCameraType;
  final bool externalCameraEnabled;
  final int cameraRotation;
  final int id;
  final bool isActive;
  final int nozzleCount;
  final int printHoursOffset;
  final bool plateDetectionEnabled;
  final String? plateDetectionRoi;
  final DateTime createdAt;
  final DateTime updatedAt;
  PrinterStatus? status;

  Printer({
    required this.name,
    required this.serialNumber,
    required this.ipAddress,
    required this.accessCode,
    required this.model,
    this.location,
    required this.autoArchive,
    this.externalCameraUrl,
    this.externalCameraType,
    required this.externalCameraEnabled,
    required this.cameraRotation,
    required this.id,
    required this.isActive,
    required this.nozzleCount,
    required this.printHoursOffset,
    required this.plateDetectionEnabled,
    this.plateDetectionRoi,
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory Printer.fromJson(Map<String, dynamic> json) {
    try {
      return Printer(
        name: json['name'] as String? ?? "",
        serialNumber: json['serial_number'] as String? ?? "",
        ipAddress: json['ip_address'] as String? ?? "",
        accessCode: json['access_code'] as String? ?? "",
        model: json['model'] as String? ?? "",
        location: json['location'] as String?,
        autoArchive: json['auto_archive'] as bool,
        externalCameraUrl: json['external_camera_url'] as String?,
        externalCameraType: json['external_camera_type'] as String?,
        externalCameraEnabled: json['external_camera_enabled'] as bool,
        cameraRotation: json['camera_rotation'] as int? ?? 0,
        id: json['id'] as int,
        isActive: json['is_active'] as bool,
        nozzleCount: json['nozzle_count'] as int? ?? 0,
        printHoursOffset: (json['print_hours_offset'] as num).toInt(),
        plateDetectionEnabled: json['plate_detection_enabled'] as bool,
        plateDetectionRoi: json['plate_detection_roi'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String? ?? ""),
        updatedAt: DateTime.parse(json['updated_at'] as String? ?? ""),
      );
    } on FormatException {
      rethrow;
    } on TypeError {
      throw FormatException('Invalid type in printer JSON data');
    } catch (e) {
      throw FormatException('Failed to parse printer JSON: $e');
    }
  }
}
