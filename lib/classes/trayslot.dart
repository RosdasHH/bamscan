import 'package:bamscan/classes/ams_spool.dart';

class TraySlot {
  final int id;
  final String trayColor;
  final String trayType;
  final String traySubBrands;
  final String trayIdName;
  final String trayInfoIdx;
  final int remain;
  final double k;
  final int caliIdx;
  final String? tagUid;
  final String? trayUuid;
  final int nozzleTempMin;
  final int nozzleTempMax;
  final int? dryingTemp;
  final int? dryingTime;
  final int state;
  AmsSpool? loadedSpool;

  TraySlot({
    required this.id,
    required this.trayColor,
    required this.trayType,
    required this.traySubBrands,
    required this.trayIdName,
    required this.trayInfoIdx,
    required this.remain,
    required this.k,
    required this.caliIdx,
    this.tagUid,
    this.trayUuid,
    required this.nozzleTempMin,
    required this.nozzleTempMax,
    this.dryingTemp,
    this.dryingTime,
    required this.state,
    this.loadedSpool,
  });

  factory TraySlot.fromJson(Map<String, dynamic> json) {
    return TraySlot(
      id: (json['id'] as num?)?.toInt() ?? 0,

      trayColor: json['tray_color'] as String? ?? "",
      trayType: json['tray_type'] as String? ?? "",
      traySubBrands: json['tray_sub_brands'] as String? ?? "",
      trayIdName: json['tray_id_name'] as String? ?? "",
      trayInfoIdx: json['tray_info_idx'] as String? ?? "",

      remain: (json['remain'] as num?)?.toInt() ?? -1,
      k: (json['k'] as num?)?.toDouble() ?? 0.0,
      caliIdx: (json['cali_idx'] as num?)?.toInt() ?? -1,

      tagUid: json['tag_uid'] as String?,
      trayUuid: json['tray_uuid'] as String?,

      nozzleTempMin: (json['nozzle_temp_min'] as num?)?.toInt() ?? 0,
      nozzleTempMax: (json['nozzle_temp_max'] as num?)?.toInt() ?? 0,

      dryingTemp: (json['drying_temp'] as num?)?.toInt(),
      dryingTime: (json['drying_time'] as num?)?.toInt(),

      state: (json['state'] as num?)?.toInt() ?? 0,
    );
  }
}
