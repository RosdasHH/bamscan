import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/services/snackbar_service.dart';
import 'package:flutter/material.dart';

class BleNotEnabled extends StatefulWidget {
  const BleNotEnabled({super.key});

  @override
  State<BleNotEnabled> createState() => _BleNotEnabledState();
}

class _BleNotEnabledState extends State<BleNotEnabled> {
  bool turningOnBluetooth = false;
  @override
  void initState() {
    super.initState();
    turnBleOn();
  }

  void turnBleOn() async {
    if (!mounted) return;
    setState(() {
      turningOnBluetooth = true;
    });
    final error = await DeviceCapabilities().turnOnBluetooth();
    if (error != null && mounted) SnackbarService.error(error);
    if (!mounted) return;
    setState(() {
      turningOnBluetooth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: turningOnBluetooth
          ? Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), Text("Turning on bluetooth..")])
          : Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.bluetooth_disabled_outlined), Text("Bluetooth not enabled!")],
            ),
    );
  }
}
