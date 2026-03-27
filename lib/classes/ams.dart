import 'package:bambuscanner/classes/trayslot.dart';

class Ams {
  final int id;
  final List<TraySlot> tray;

  const Ams({required this.id, required this.tray});

  factory Ams.fromJson(Map<String, dynamic> json) {
    final List<dynamic> trayRaw = json['tray'] as List;
    final List<TraySlot> tray = trayRaw
        .map((e) => TraySlot.fromJson(e as Map<String, dynamic>))
        .toList();

    return Ams(id: json['id'] as int, tray: tray);
  }
}
