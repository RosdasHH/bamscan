import 'dart:convert';

import 'package:bamscan/classes/printer_status.dart';
import 'package:bamscan/services/api.dart';
import 'package:bamscan/services/globals.dart';
import 'package:bamscan/services/snackbar_service.dart';
import 'package:bamscan/services/storage.dart';

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
  final Map<String, dynamic>? amsLabels;
  final Maintenance maintenance;
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
    this.amsLabels,
    required this.maintenance,
  });

  static Future<Printer> fromJson(Map<String, dynamic> json) async {
    Future<Map<String, dynamic>> getAmsLabels(int printerid) async {
      final res = await ApiService().apiReq("/printers/${printerid.toString()}/ams-labels");
      final json = jsonDecode(res.body);
      return json;
    }

    try {
      int id = json['id'] as int;
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
        id: id,
        isActive: json['is_active'] as bool,
        nozzleCount: json['nozzle_count'] as int? ?? 0,
        printHoursOffset: (json['print_hours_offset'] as num).toInt(),
        plateDetectionEnabled: json['plate_detection_enabled'] as bool,
        plateDetectionRoi: json['plate_detection_roi'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String? ?? ""),
        updatedAt: DateTime.parse(json['updated_at'] as String? ?? ""),
        amsLabels: await getAmsLabels(id),
        maintenance: await Maintenance.get(id.toString()),
      );
    } catch (e) {
      SnackbarService.error(e.toString());
      rethrow;
    }
  }

  String getImgUrl() {
    return "${StorageService().getString(StorageService.kBambuddyUrl)}${Globals.imagesnamespace}${model.replaceAll(" ", "").toLowerCase()}.png";
  }
}

class Maintenance {
  final double currentHours;
  Maintenance({required this.currentHours});
  static Future<Maintenance> get(String printerid) async {
    final res = await ApiService().apiReq("/maintenance/printers/$printerid");
    final json = jsonDecode(res.body);
    return Maintenance(currentHours: json["total_print_hours"] as double? ?? 0);
  }
}
