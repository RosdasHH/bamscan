import 'dart:async';

import 'package:bamscan/classes/scale.dart';
import 'package:bamscan/services/ble.dart';

class ScaleService {
  ScaleService._internal();
  static final ScaleService _instance = ScaleService._internal();
  factory ScaleService() => _instance;

  final _controller = StreamController<Scale>.broadcast();

  Stream<Scale> get stream => _controller.stream;

  StreamSubscription? _sub;

  void start() {
    _sub?.cancel();

    _sub = Ble().notifications.listen((value) {
      try {
        if (value.length < 7) return;

        final raw = (value[4] << 16) | (value[5] << 8) | value[6];

        final weight = raw / 1000;

        _controller.add(Scale(weight: weight, isStable: value[2] == 1));
      } catch (_) {}
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
