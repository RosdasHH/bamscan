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
  });

  factory TraySlot.fromJson(Map<String, dynamic> json) {
    return TraySlot(
      id: json['id'] as int,
      trayColor: json['tray_color'] as String,
      trayType: json['tray_type'] as String,
      traySubBrands: json['tray_sub_brands'] as String,
      trayIdName: json['tray_id_name'] as String,
      trayInfoIdx: json['tray_info_idx'] as String,
      remain: json['remain'] as int,
      k: (json['k'] as num).toDouble(),
      caliIdx: json['cali_idx'] as int,
      tagUid: json['tag_uid'] as String?,
      trayUuid: json['tray_uuid'] as String?,
      nozzleTempMin: json['nozzle_temp_min'] as int,
      nozzleTempMax: json['nozzle_temp_max'] as int,
      dryingTemp: json['drying_temp'] as int?,
      dryingTime: json['drying_time'] as int?,
      state: json['state'] as int,
    );
  }
}