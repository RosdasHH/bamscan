import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class DeviceCapabilities extends ChangeNotifier {
  bool _isNfcAvailable = false;
  bool get isNfcAvailable => _isNfcAvailable;

  static final DeviceCapabilities _instance = DeviceCapabilities._internal();
  factory DeviceCapabilities() => _instance;
  DeviceCapabilities._internal();

  void checkDevicesCapabilities() async {
    _isNfcAvailable = await NfcManager.instance.isAvailable();
  }
}
