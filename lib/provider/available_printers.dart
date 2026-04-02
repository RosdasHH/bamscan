import 'dart:convert';

import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/printer.dart';
import 'package:bambuscanner/services/api.dart';
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

      setPrinters(printers);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Ams>> getAmsByPrinterId(String id) async {
    final http.Response res = await ApiService().apiReq("/printers/$id/status");
    final List<dynamic> jsonList = jsonDecode(res.body)["ams"] as List;

    final List<Ams> ams = jsonList
        .map((e) => Ams.fromJson(e as Map<String, dynamic>))
        .toList();

    return ams;
  }
}
