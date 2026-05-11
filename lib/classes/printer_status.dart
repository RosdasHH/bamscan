import 'package:bamscan/services/snackbar_service.dart';

class PrinterStatus {
  final int id;
  final String name;
  final bool connected;
  final String state;
  final String currentPrint;
  final String subtaskName;
  final String gcodeFile;
  final int progress;
  final int remainingTime;
  final int layerNum;
  final int totalLayers;
  final String? coverUrl;
  final Temperatures temperatures;
  final int rssi;
  final bool ipCam;
  final bool sdcard;
  final String firmwareVersion;
  const PrinterStatus({
    required this.id,
    required this.name,
    required this.connected,
    required this.state,
    required this.currentPrint,
    required this.subtaskName,
    required this.gcodeFile,
    required this.progress,
    required this.remainingTime,
    required this.layerNum,
    required this.totalLayers,
    this.coverUrl,
    required this.temperatures,
    required this.rssi,
    required this.ipCam,
    required this.sdcard,
    required this.firmwareVersion,
  });

  factory PrinterStatus.fromJson(Map<String, dynamic> json) {
    try {
      return PrinterStatus(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] ?? '',
        connected: json['connected'] ?? false,
        state: json['state'] ?? '',
        currentPrint: json['current_print'] ?? '',
        subtaskName: json['subtask_name'] ?? '',
        gcodeFile: json['gcode_file'] ?? '',
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        remainingTime: (json['remaining_time'] as num?)?.toInt() ?? 0,
        layerNum: (json['layer_num'] as num?)?.toInt() ?? 0,
        totalLayers: (json['total_layers'] as num?)?.toInt() ?? 0,
        temperatures: Temperatures.fromJson(json["temperatures"]),
        rssi: (json["wifi_signal"] as num?)?.toInt() ?? 0,
        ipCam: json["ipcam"] ?? false,
        sdcard: json["sdcard"] ?? false,
        firmwareVersion: json["firmware_version"] ?? "",

        coverUrl: json['cover_url'],
      );
    } catch (e) {
      SnackbarService.error(e.toString());
      rethrow;
    }
  }
}

class Temperatures {
  final double bed;
  final double bedTarget;
  final double nozzle;
  final double nozzleTarget;
  final bool nozzleHeating;
  const Temperatures({required this.bed, required this.bedTarget, required this.nozzle, required this.nozzleTarget, required this.nozzleHeating});
  factory Temperatures.fromJson(Map<String, dynamic> json) {
    return Temperatures(
      bed: json["bed"] ?? 0,
      bedTarget: json["bed_target"] ?? 0,
      nozzle: json["nozzle"] ?? 0,
      nozzleTarget: json["nozzle_target"] ?? 0,
      nozzleHeating: json["nozzle_heating"] ?? false,
    );
  }
}
