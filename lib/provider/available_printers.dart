import 'dart:convert';

import 'package:bambuscanner/api.dart';
import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/printer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvailablePrinters extends ChangeNotifier {
  final List<Printer> _printers = [];

  List<Printer> get printers => List.unmodifiable(_printers);

  void setPrinters(List<Printer> newList) {
    _printers
      ..clear()
      ..addAll(newList);
    print("Printers set");
    notifyListeners();
  }

  Future<void> fetchPrinters() async {
    final http.Response res = await apiReq("/printers/");
    final List<dynamic> jsonList = jsonDecode(res.body) as List<dynamic>;
    final List<Printer> printers = jsonList
        .map((e) => Printer.fromJson(e as Map<String, dynamic>))
        .toList();

    setPrinters(printers);
  }

  Future<List<Ams>> getAmsByPrinterId(String id) async {
    final http.Response res = await apiReq("/printers/$id/status");
    final List<dynamic> jsonList = jsonDecode(res.body)["ams"] as List;

    final List<Ams> ams = jsonList
        .map((e) => Ams.fromJson(e as Map<String, dynamic>))
        .toList();

    return ams;
  }
}
