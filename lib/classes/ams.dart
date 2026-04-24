import 'package:bamscan/classes/trayslot.dart';

class Ams {
  final int id;
  final List<TraySlot> tray;
  final bool isExternalSpool;

  const Ams({
    required this.id,
    required this.tray,
    this.isExternalSpool = false,
  });

  factory Ams.fromJson(Map<String, dynamic> json) {
    final List<dynamic> trayRaw = json['tray'] as List;
    final List<TraySlot> tray = trayRaw
        .map((e) => TraySlot.fromJson(e as Map<String, dynamic>))
        .toList();

    return Ams(id: json['id'] as int, tray: tray);
  }
}
