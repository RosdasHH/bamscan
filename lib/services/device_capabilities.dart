import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';

class DeviceCapabilities extends ChangeNotifier {
  bool _isNfcAvailable = false;
  bool _isBluetoothAvailable = false;
  bool _isBluetoothSupported = false;
  bool get isNfcAvailable => _isNfcAvailable;
  bool get isBluetoothAvailable => _isBluetoothAvailable;
  bool get isBluetoothSupported => _isBluetoothSupported;

  StreamSubscription<BluetoothAdapterState>? _bluetoothSubscription;

  static final DeviceCapabilities _instance = DeviceCapabilities._internal();
  factory DeviceCapabilities() => _instance;
  DeviceCapabilities._internal();

  void checkDevicesCapabilities() async {
    _isNfcAvailable = await NfcManager.instance.isAvailable();
    _isBluetoothSupported = await FlutterBluePlus.isSupported;
    if (_isBluetoothSupported) {
      final state = FlutterBluePlus.adapterStateNow;
      _updateBluetoothState(state);

      _bluetoothSubscription?.cancel();

      _bluetoothSubscription = FlutterBluePlus.adapterState.listen((state) {
        _updateBluetoothState(state);
      });
    }
  }

  void _updateBluetoothState(BluetoothAdapterState state) {
    _isBluetoothAvailable = state == BluetoothAdapterState.on;
    notifyListeners();
  }

  Future<String?> turnOnBluetooth() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        return e.toString();
      }
    }
    return null;
  }

  void disposeListener() {
    _bluetoothSubscription?.cancel();
  }
}
