import 'package:bamscan/utils/color.dart';
import 'package:bamscan/utils/parse_note.dart';
import 'package:flutter/material.dart';

class Spool {
  final String material;
  final String subtype;
  final String colorName;
  final Color color;
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
  final String? nfcid;
  Assignment? assignment;

  Spool({
    required this.material,
    required this.subtype,
    required this.colorName,
    required this.color,
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
    this.assignment,
    this.nfcid,
  });

  factory Spool.fromJson(Map<String, dynamic> json) {
    try {
      return Spool(
        material: json['material'] as String? ?? "",
        subtype: json['subtype'] as String? ?? "",
        colorName: json['color_name'] as String? ?? "",
        color: toFlutterColor(json['rgba']),
        brand: json['brand'] as String? ?? "",
        labelWeight: (json['label_weight'] as num?)?.toInt() ?? 0,
        coreWeight: (json['core_weight'] as num?)?.toInt() ?? 0,
        coreWeightCatalogId: json['core_weight_catalog_id'] != null
            ? (json['core_weight_catalog_id'] as num).toInt()
            : null,
        weightUsed: (json['weight_used'] as num?)?.toInt() ?? 0,
        slicerFilament: json['slicer_filament'] as String? ?? "",
        slicerFilamentName: json['slicer_filament_name'] as String? ?? "",
        nozzleTempMin: (json['nozzle_temp_min'] as num?)?.toInt() ?? 0,
        nozzleTempMax: (json['nozzle_temp_max'] as num?)?.toInt() ?? 0,
        note: json['note'] as String? ?? "",
        tagUid: json['tag_uid'] as String? ?? "",
        trayUuid: json['tray_uuid'] as String? ?? "",
        dataOrigin: json['data_origin'] as String? ?? "",
        tagType: json['tag_type'] as String? ?? "",
        costPerKg: (json['cost_per_kg'] as num?)?.toDouble() ?? 0.0,
        weightLocked: json['weight_locked'] as bool,
        lastScaleWeight: json['last_scale_weight'] as int? ?? 0,
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
        createdAt: DateTime.parse(json['created_at'] as String? ?? ""),
        updatedAt: DateTime.parse(json['updated_at'] as String? ?? ""),
        kProfiles: json['k_profiles'] as List<dynamic>? ?? [],
        qrcode: (json["note"] as String?) != null
            ? parseQrCodeFromString(json["note"])
            : null,
        nfcid: (json["note"] as String?) != null
            ? parseNfcIdentifierFromString(json["note"])
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class Assignment {
  final int amsId;
  final int trayId;
  final String printerName;

  Assignment({
    required this.amsId,
    required this.trayId,
    required this.printerName,
  });

  Map<String, dynamic> toMap() {
    return {"amsId": amsId, "trayId": trayId, "printerName": printerName};
  }
}
