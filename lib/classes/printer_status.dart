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

  final Temperatures temperatures;

  final String? coverUrl;
  final List<dynamic> hmsErrors;

  final List<Map<String, dynamic>> ams;
  final bool amsExists;
  final List<Map<String, dynamic>> vtTray;

  final bool sdcard;
  final bool storeToSdcard;
  final bool timelapse;
  final bool ipcam;
  final int wifiSignal;
  final bool wiredNetwork;

  final List<Nozzle> nozzles;
  final List<dynamic> nozzleRack;

  final Map<String, dynamic> printOptions;

  final int stgCur;
  final String? stgCurName;
  final List<dynamic> stg;

  final int airductMode;
  final int speedLevel;
  final bool chamberLight;
  final int activeExtruder;

  final List<dynamic> amsMapping;
  final Map<String, dynamic> amsExtruderMap;

  final int trayNow;
  final int amsStatusMain;
  final int amsStatusSub;
  final int mcPrintSubStage;

  final double lastAmsUpdate;
  final int printableObjectsCount;

  final int coolingFanSpeed;
  final int bigFan1Speed;
  final int bigFan2Speed;
  final int heatbreakFanSpeed;

  final String firmwareVersion;
  final dynamic developerMode;

  final bool plateCleared;
  final bool supportsDrying;

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
    required this.temperatures,
    this.coverUrl,
    required this.hmsErrors,
    required this.ams,
    required this.amsExists,
    required this.vtTray,
    required this.sdcard,
    required this.storeToSdcard,
    required this.timelapse,
    required this.ipcam,
    required this.wifiSignal,
    required this.wiredNetwork,
    required this.nozzles,
    required this.nozzleRack,
    required this.printOptions,
    required this.stgCur,
    this.stgCurName,
    required this.stg,
    required this.airductMode,
    required this.speedLevel,
    required this.chamberLight,
    required this.activeExtruder,
    required this.amsMapping,
    required this.amsExtruderMap,
    required this.trayNow,
    required this.amsStatusMain,
    required this.amsStatusSub,
    required this.mcPrintSubStage,
    required this.lastAmsUpdate,
    required this.printableObjectsCount,
    required this.coolingFanSpeed,
    required this.bigFan1Speed,
    required this.bigFan2Speed,
    required this.heatbreakFanSpeed,
    required this.firmwareVersion,
    this.developerMode,
    required this.plateCleared,
    required this.supportsDrying,
  });

  factory PrinterStatus.fromJson(Map<String, dynamic> json) {
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

      coverUrl: json['cover_url'],
      hmsErrors: json['hms_errors'] ?? [],

      ams: (json['ams'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList(),

      amsExists: json['ams_exists'] ?? false,

      vtTray: (json['vt_tray'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList(),

      sdcard: json['sdcard'] ?? false,
      storeToSdcard: json['store_to_sdcard'] ?? false,
      timelapse: json['timelapse'] ?? false,
      ipcam: json['ipcam'] ?? false,
      wifiSignal: (json['wifi_signal'] as num?)?.toInt() ?? 0,
      wiredNetwork: json['wired_network'] ?? false,

      nozzles: (json['nozzles'] as List<dynamic>? ?? [])
          .map((e) => Nozzle.fromJson(e))
          .toList(),

      nozzleRack: json['nozzle_rack'] ?? [],

      printOptions: (json['print_options'] as Map<String, dynamic>?) ?? {},

      stgCur: (json['stg_cur'] as num?)?.toInt() ?? 0,
      stgCurName: json['stg_cur_name'],
      stg: json['stg'] ?? [],

      airductMode: (json['airduct_mode'] as num?)?.toInt() ?? 0,
      speedLevel: (json['speed_level'] as num?)?.toInt() ?? 0,
      chamberLight: json['chamber_light'] ?? false,
      activeExtruder: (json['active_extruder'] as num?)?.toInt() ?? 0,

      amsMapping: json['ams_mapping'] ?? [],
      amsExtruderMap: (json['ams_extruder_map'] as Map<String, dynamic>?) ?? {},

      trayNow: (json['tray_now'] as num?)?.toInt() ?? 0,
      amsStatusMain: (json['ams_status_main'] as num?)?.toInt() ?? 0,
      amsStatusSub: (json['ams_status_sub'] as num?)?.toInt() ?? 0,
      mcPrintSubStage: (json['mc_print_sub_stage'] as num?)?.toInt() ?? 0,

      lastAmsUpdate: (json['last_ams_update'] as num?)?.toDouble() ?? 0,

      printableObjectsCount:
          (json['printable_objects_count'] as num?)?.toInt() ?? 0,

      coolingFanSpeed: (json['cooling_fan_speed'] as num?)?.toInt() ?? 0,
      bigFan1Speed: (json['big_fan1_speed'] as num?)?.toInt() ?? 0,
      bigFan2Speed: (json['big_fan2_speed'] as num?)?.toInt() ?? 0,
      heatbreakFanSpeed: (json['heatbreak_fan_speed'] as num?)?.toInt() ?? 0,

      firmwareVersion: json['firmware_version'] ?? '',
      developerMode: json['developer_mode'],

      plateCleared: json['plate_cleared'] ?? false,
      supportsDrying: json['supports_drying'] ?? false,
    );
  }
}

class Temperatures {
  final double bed;
  final double bedTarget;
  final double nozzle;
  final double nozzleTarget;
  final bool nozzleHeating;
  const Temperatures({
    required this.bed,
    required this.bedTarget,
    required this.nozzle,
    required this.nozzleTarget,
    required this.nozzleHeating,
  });
  factory Temperatures.fromJson(Map<String, dynamic> json) {
    return Temperatures(
      bed: json["bed"] as double,
      bedTarget: json["bed_target"] as double,
      nozzle: json["nozzle"] as double,
      nozzleTarget: json["nozzle_target"] as double,
      nozzleHeating: json["nozzleHeating"] ?? false,
    );
  }
}

class Nozzle {
  final String nozzleType;
  final double nozzleDiameter;
  const Nozzle({required this.nozzleType, required this.nozzleDiameter});

  factory Nozzle.fromJson(Map<String, dynamic> json) {
    double diameter = 0.0;
    try {
      diameter = double.parse(json["nozzle_diameter"]?.toString() ?? "0.0");
    } catch (e) {
      diameter = 0.0;
    }
    return Nozzle(
      nozzleType: json["nozzle_type"] ?? "",
      nozzleDiameter: diameter,
    );
  }
}
