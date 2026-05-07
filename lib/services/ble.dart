import 'dart:async';

import 'package:bamscan/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Ble with WidgetsBindingObserver {
  Ble._internal();
  static final Ble _instance = Ble._internal();
  factory Ble() {
    return _instance;
  }

  Stream<ScanResult> fetchDevices() {
    final controller = StreamController<ScanResult>.broadcast();
    StreamSubscription? scanSub;

    controller.onListen = () {
      if (!FlutterBluePlus.isScanningNow) {
        FlutterBluePlus.startScan(timeout: Duration(seconds: 15), androidUsesFineLocation: true);
      }
      scanSub = FlutterBluePlus.onScanResults.listen((res) {
        for (final r in res) {
          controller.add(r);
        }
      });
    };
    controller.onCancel = () {
      FlutterBluePlus.stopScan();
      scanSub?.cancel();
    };
    return controller.stream;
  }

  void connect({BluetoothDevice? device}) async {
    bool autoConnect = false;
    if (device == null) {
      final id = StorageService().bleRemoteId;
      if (id == "") return;
      device = BluetoothDevice.fromId(StorageService().bleRemoteId);
      autoConnect = true;
    }

    var sub = device.connectionState.listen((a) {
      print("$a");
    });
    device.cancelWhenDisconnected(sub, delayed: true, next: true);

    await device.connect(license: License.free);

    if (!autoConnect) {
      StorageService().setBleRemoteId(device.remoteId.toString());
    }
  }
}
