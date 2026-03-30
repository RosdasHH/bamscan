class Spool {
  final String material;
  final String subtype;
  final String colorName;
  final String rgba;
  final String brand;
  final int labelWeight;
  final int coreWeight;
  final int? coreWeightCatalogId;
  final int weightUsed;
  final String slicerFilament;
  final String slicerFilamentName;
  final int? nozzleTempMin;
  final int? nozzleTempMax;
  final String? note;
  final String? tagUid;
  final String? trayUuid;
  final String? dataOrigin;
  final String? tagType;
  final double? costPerKg;
  final bool weightLocked;
  final int? lastScaleWeight;
  final DateTime? lastWeighedAt;
  final int id;
  final DateTime? addedFull;
  final DateTime? lastUsed;
  final DateTime? encodeTime;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> kProfiles;
  final String? qrcode;

  const Spool({
    required this.material,
    required this.subtype,
    required this.colorName,
    required this.rgba,
    required this.brand,
    required this.labelWeight,
    required this.coreWeight,
    required this.coreWeightCatalogId,
    required this.weightUsed,
    required this.slicerFilament,
    required this.slicerFilamentName,
    this.nozzleTempMin,
    this.nozzleTempMax,
    this.note,
    this.tagUid,
    this.trayUuid,
    this.dataOrigin,
    this.tagType,
    required this.costPerKg,
    required this.weightLocked,
    this.lastScaleWeight,
    this.lastWeighedAt,
    required this.id,
    this.addedFull,
    this.lastUsed,
    this.encodeTime,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.kProfiles,
    this.qrcode,
  });

  factory Spool.fromJson(Map<String, dynamic> json) {
    final qrRegex = RegExp(r'\[QR-CODE\]=>\[(.*?)\]');
    try {
      return Spool(
        material: json['material'] as String,
        subtype: json['subtype'] as String,
        colorName: json['color_name'] as String,
        rgba: json['rgba'] as String,
        brand: json['brand'] as String,
        labelWeight: (json['label_weight'] as num).toInt(),
        coreWeight: (json['core_weight'] as num).toInt(),
        coreWeightCatalogId: json['core_weight_catalog_id'] != null
            ? (json['core_weight_catalog_id'] as num).toInt()
            : null,
        weightUsed: (json['weight_used'] as num).toInt(),
        slicerFilament: json['slicer_filament'] as String,
        slicerFilamentName: json['slicer_filament_name'] as String,
        nozzleTempMin: json['nozzle_temp_min'] as int?,
        nozzleTempMax: json['nozzle_temp_max'] as int?,
        note: json['note'] as String?,
        tagUid: json['tag_uid'] as String?,
        trayUuid: json['tray_uuid'] as String?,
        dataOrigin: json['data_origin'] as String?,
        tagType: json['tag_type'] as String?,
        costPerKg: (json['cost_per_kg'] as num?)?.toDouble(),
        weightLocked: json['weight_locked'] as bool,
        lastScaleWeight: json['last_scale_weight'] as int?,
        lastWeighedAt: json['last_weighed_at'] != null
            ? DateTime.parse(json['last_weighed_at'] as String)
            : null,
        id: json['id'] as int,
        addedFull: json['added_full'] != null
            ? DateTime.parse(json['added_full'] as String)
            : null,
        lastUsed: json['last_used'] != null
            ? DateTime.parse(json['last_used'] as String)
            : null,
        encodeTime: json['encode_time'] != null
            ? DateTime.parse(json['encode_time'] as String)
            : null,
        archivedAt: json['archived_at'] != null
            ? DateTime.parse(json['archived_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        kProfiles: json['k_profiles'] as List<dynamic>,
        qrcode: (json["note"] as String?) != null
            ? qrRegex.firstMatch(json["note"]!)?.group(1)
            : null,
      );
    } catch (e) {
      throw (e);
    }
  }
}
