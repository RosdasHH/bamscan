import 'dart:convert';

import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvailableFilaments extends ChangeNotifier {
  final List<Spool> _spools = [];

  List<Spool> get spools => List.unmodifiable(_spools);

  void setFilaments(List<Spool> newList) {
    _spools
      ..clear()
      ..addAll(newList);
    notifyListeners();
  }

  Future<Spool> getSpoolById(String id) async {
    http.Response res = await apiReq("/inventory/spools/$id");
    Spool spool = Spool.fromJson(jsonDecode(res.body));
    return spool;
  }

  Future<bool> setSlotToSpoolId(
    String printerid,
    String amsid,
    String trayid,
    String spoolid,
  ) async {
    final res = await apiPost("/inventory/assignments", {
      "spool_id": int.parse(spoolid),
      "printer_id": int.parse(printerid),
      "ams_id": int.parse(amsid),
      "tray_id": int.parse(trayid),
    });
    final Map<String, dynamic> json = jsonDecode(res.body);
    bool configured = json["configured"];
    return configured;
  }

  Future<bool> patchSpool(String id, String note) async {
    final res = await apiPatch("/inventory/spools/$id", {"note": note});
    if (res.statusCode != 200) return false;

    Spool updatedSpool = Spool.fromJson(jsonDecode(res.body));

    final int index = _spools.indexWhere((s) => s.id.toString() == id);

    if (index != -1) {
      List<Spool> spoolsCopy = List.from(_spools);
      spoolsCopy[index] = updatedSpool;
      setFilaments(spoolsCopy);
    }
    return res.statusCode == 200;
  }

  Future<bool?> getAllSpools() async {
    final res = await apiReq("/inventory/spools");
    final List<dynamic> data = jsonDecode(res.body);
    setFilaments(
      data.map((e) => Spool.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return true;
  }

  Future<List<Spool>> getSpoolsByQrCode(String qrcode) async {
    final List<Spool> allSpools = _spools;
    List<Spool> spools = [];
    for (Spool spool in allSpools) {
      if (spool.qrcode != null && spool.qrcode == qrcode) {
        spools.add(spool);
      }
    }
    return spools;
  }

  Future<List<AmsSpool>> getAllFilamentMappings() async {
    final res = await apiReq("/inventory/assignments");
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .map((e) => AmsSpool.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AmsSpool>> getFilamentMappingForPrinter(int printerId) async {
    final res = await apiReq("/inventory/assignments?printer_id=$printerId");
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .map((e) => AmsSpool.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
