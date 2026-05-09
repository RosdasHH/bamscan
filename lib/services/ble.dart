import 'dart:async';

import 'package:bamscan/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Ble extends ChangeNotifier with WidgetsBindingObserver {
  Ble._internal();
  static final Ble _instance = Ble._internal();
  factory Ble() => _instance;

  BluetoothDevice? connectedDevice;
  bool isConnecting = false;

  final StreamController<List<int>> _notifyController = StreamController<List<int>>.broadcast();

  Stream<List<int>> get notifications => _notifyController.stream;

  StreamSubscription? _notifySub;
  StreamSubscription? _connectionSub;

  Stream<ScanResult> fetchDevices() {
    final controller = StreamController<ScanResult>.broadcast();
    StreamSubscription? scanSub;

    controller.onListen = () {
      if (!FlutterBluePlus.isScanningNow) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: true);
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

  Future<void> connect({BluetoothDevice? device}) async {
    await disconnectCurrent();

    bool autoConnect = false;

    if (device == null) {
      final id = StorageService().bleRemoteId;
      if (id.isEmpty) return;

      device = BluetoothDevice.fromId(id);
      autoConnect = true;
    }

    await _connectionSub?.cancel();

    _connectionSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        connectedDevice = null;
        notifyListeners();
      } else if (state == BluetoothConnectionState.connected) {
        connectedDevice = device;
        notifyListeners();
      }
    });

    if (!autoConnect) {
      StorageService().setBleRemoteId(device.remoteId.toString());
    }
    isConnecting = true;
    try {
      await device.connect(license: License.free);
    } catch (e) {
      connect();
      return;
    }
    isConnecting = false;

    connectedDevice = device;
    notifyListeners();

    _startNotifications(device);
  }

  void _startNotifications(BluetoothDevice device) async {
    await _notifySub?.cancel();
    _notifySub = null;

    final services = await device.discoverServices();

    for (final s in services) {
      for (final c in s.characteristics) {
        if (c.properties.notify || c.properties.indicate) {
          await c.setNotifyValue(true);

          _notifySub = c.lastValueStream.listen((value) {
            _notifyController.add(value);
          });
        }
      }
    }
  }

  Future<void> disconnectCurrent() async {
    await _notifySub?.cancel();
    _notifySub = null;

    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (_) {}
    }

    connectedDevice = null;

    await FlutterBluePlus.stopScan();
  }
}
