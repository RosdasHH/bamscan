import 'package:bamscan/classes/printer.dart';
import 'package:bamscan/classes/trayslot.dart';
import 'package:bamscan/services/snackbar_service.dart';

class Ams {
  final int id;
  final List<TraySlot> tray;
  final bool isExternalSpool;
  final String amsLabel;

  const Ams({required this.id, required this.tray, this.isExternalSpool = false, required this.amsLabel});

  factory Ams.fromJson(Map<String, dynamic> json, Printer printer) {
    try {
      final int id = json['id'] as int;
      final List<dynamic> trayRaw = json['tray'] as List;
      final List<TraySlot> tray = trayRaw.map((e) => TraySlot.fromJson(e as Map<String, dynamic>)).toList();
      final String amsLabel = printer.amsLabels?["$id"] ?? "AMS ${id + 1}";

      return Ams(id: id, tray: tray, amsLabel: amsLabel);
    } catch (e) {
      SnackbarService.error(e.toString());
      rethrow;
    }
  }
}
