import 'dart:convert';

import 'package:bamscan/classes/ams.dart';
import 'package:bamscan/classes/printer.dart';
import 'package:bamscan/classes/printer_status.dart';
import 'package:bamscan/classes/trayslot.dart';
import 'package:bamscan/services/api.dart';
import 'package:bamscan/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvailablePrinters extends ChangeNotifier {
  final List<Printer> _printers = [];
  bool _printersSet = false;

  List<Printer> get printers => List.unmodifiable(_printers);
  bool get printersSet => _printersSet;

  void setPrinters(List<Printer> newList) {
    if (_printers != newList) {
      _printers
        ..clear()
        ..addAll(newList);
      _printersSet = true;
      notifyListeners();
    }
  }

  Future<void> fetchPrinters() async {
    try {
      final http.Response res = await ApiService().apiReq("/printers/");
      final List<dynamic> jsonList = jsonDecode(res.body) as List<dynamic>;
      final List<Printer> printers = jsonList
          .map((e) => Printer.fromJson(e as Map<String, dynamic>))
          .toList();
      for (Printer printer in printers) {
        printer.status = await getPrinterStatus(printer.id);
      }
      setPrinters(printers);
    } catch (_) {}
  }

  Future<List<Ams>> getAmsByPrinterId(String id) async {
    final http.Response res = await ApiService().apiReq("/printers/$id/status");
    final List<dynamic> amsList = jsonDecode(res.body)["ams"] as List;
    final List<dynamic> vtrayList = jsonDecode(res.body)["vt_tray"] as List;

    final List<Ams> ams = amsList
        .map((e) => Ams.fromJson(e as Map<String, dynamic>))
        .toList();
    if (StorageService().externalSpool) {
      final List<TraySlot> vtTray = vtrayList
          .map((e) => TraySlot.fromJson(e as Map<String, dynamic>))
          .toList();
      final Ams vttrayams = Ams(id: 255, tray: vtTray, isExternalSpool: true);
      ams.add(vttrayams);
    }
    return ams;
  }

  Future<PrinterStatus> getPrinterStatus(int id) async {
    final http.Response res = await ApiService().apiReq("/printers/$id/status");
    final dynamic jsonList = jsonDecode(res.body);
    final printerStatus = PrinterStatus.fromJson(jsonList);
    return printerStatus;
  }

  Future<bool> resetSlot(String printerId, String amsId, String trayId) async {
    try {
      final res = await ApiService().apiPost(
        "/printers/$printerId/ams/$amsId/tray/$trayId/reset",
        {},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
