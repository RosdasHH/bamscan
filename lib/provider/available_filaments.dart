import 'dart:convert';

import 'package:bamscan/classes/ams.dart';
import 'package:bamscan/classes/ams_spool.dart';
import 'package:bamscan/classes/slot_preset.dart';
import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/classes/trayslot.dart';
import 'package:bamscan/services/api.dart';
import 'package:bamscan/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvailableFilaments extends ChangeNotifier {
  final List<Spool> _spools = [];
  bool _filamentsSet = false;

  List<Spool> get spools => List.unmodifiable(_spools);
  bool get filamentsSet => _filamentsSet;

  void setFilaments(List<Spool> newList) {
    if (_spools != newList) {
      _spools
        ..clear()
        ..addAll(newList);
      _filamentsSet = true;
      notifyListeners();
    }
  }

  Future<Spool> getSpoolById(String id) async {
    http.Response res = await ApiService().apiReq("/inventory/spools/$id");
    Spool spool = Spool.fromJson(jsonDecode(res.body));
    return spool;
  }

  Future<SlotPreset> getPreset(String printerid, String amsid, String trayid) async {
    http.Response res = await ApiService().apiReq("/printers/$printerid/slot-presets/$amsid/$trayid");
    SlotPreset preset = SlotPreset.fromJson(jsonDecode(res.body));
    return preset;
  }

  Future<bool> setSlotToSpoolId(String printerid, String amsid, String trayid, String spoolid) async {
    final res = await ApiService().apiPost("/inventory/assignments", {
      "spool_id": int.parse(spoolid),
      "printer_id": int.parse(printerid),
      "ams_id": int.parse(amsid),
      "tray_id": int.parse(trayid),
    });
    final Map<String, dynamic> json = jsonDecode(res.body);
    bool configured = json["configured"];
    return configured;
  }

  Future<bool> patchSpool(String id, Map<String, dynamic> content) async {
    final res = await ApiService().apiPatch("/inventory/spools/$id", content);
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

  Future<void> archive(String id) async {
    try {
      final res = await ApiService().apiPost("/inventory/spools/$id/archive", {});
      removeSpoolByRes(res);
    } catch (_) {}
  }

  Future<void> removeSpoolByRes(http.Response res) async {
    List<Spool> spoolsCopy = List.from(_spools);
    Spool archivedSpool = Spool.fromJson(jsonDecode(res.body));
    spoolsCopy.remove(archivedSpool);
    setFilaments(spoolsCopy);
  }

  Future<bool?> getAllSpools() async {
    final res = await ApiService().apiReq("/inventory/spools");
    final List<dynamic> data = jsonDecode(res.body);
    try {
      List<AmsSpool> assignments = await getAllFilamentMappings();
      List<Spool> filaments = data.map((e) => Spool.fromJson(e as Map<String, dynamic>)).toList();
      for (Spool filament in filaments) {
        for (AmsSpool assignment in assignments) {
          if (filament.id == assignment.spoolId) {
            filament.assignment = Assignment(amsId: assignment.amsId, trayId: assignment.trayId, printerName: assignment.printerName.toString());
            break;
          }
        }
      }
      setFilaments(filaments);
      return true;
    } catch (_) {}
    return null;
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

  Future<List<Spool>> getSpoolsByNfc(String nfcid) async {
    final List<Spool> allSpools = _spools;
    List<Spool> spools = [];
    for (Spool spool in allSpools) {
      if (spool.nfcid != null && spool.nfcid == nfcid) {
        spools.add(spool);
      }
    }
    return spools;
  }

  Future<List<AmsSpool>> getAllFilamentMappings() async {
    try {
      final res = await ApiService().apiReq("/inventory/assignments");
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => AmsSpool.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unassignSpool(String printerId, String amsId, String trayId) async {
    await ApiService().apiDel("/inventory/assignments/$printerId/$amsId/$trayId");
    return;
  }

  Future<List<AmsSpool>> getFilamentMappingForPrinter(int printerId) async {
    final res = await ApiService().apiReq("/inventory/assignments?printer_id=$printerId");
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => AmsSpool.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Ams>> getAllAms(int printerId) async {
    final List<AmsSpool> filamentMappingsforPrinter = await getFilamentMappingForPrinter(printerId);
    final List<Ams> amsForPrinter = await getAmsByPrinterId(printerId.toString());
    for (Ams ams in amsForPrinter) {
      for (TraySlot tray in ams.tray) {
        for (AmsSpool mapping in filamentMappingsforPrinter) {
          if (ams.id == mapping.amsId && tray.id == mapping.trayId) {
            tray.loadedSpool = mapping;
          }
        }
      }
    }
    return amsForPrinter;
  }

  Future<List<Ams>> getAmsByPrinterId(String id) async {
    final http.Response res = await ApiService().apiReq("/printers/$id/status");
    final List<dynamic> amsList = jsonDecode(res.body)["ams"] as List;
    final List<dynamic> vtrayList = jsonDecode(res.body)["vt_tray"] as List;

    final List<Ams> ams = amsList.map((e) => Ams.fromJson(e as Map<String, dynamic>)).toList();
    if (StorageService().externalSpool) {
      final List<TraySlot> vtTray = vtrayList.map((e) => TraySlot.fromJson(e as Map<String, dynamic>)).toList();
      final Ams vttrayams = Ams(id: 255, tray: vtTray, isExternalSpool: true);
      ams.add(vttrayams);
    }
    return ams;
  }
}
