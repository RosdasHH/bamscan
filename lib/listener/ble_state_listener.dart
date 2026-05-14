import 'package:bamscan/helper/showSnackbar.dart';
import 'package:bamscan/services/ble.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class Blestatelistener extends StatefulWidget {
  const Blestatelistener({super.key, required this.child});
  final Widget child;

  @override
  State<Blestatelistener> createState() => _BlestatelistenerState();
}

class _BlestatelistenerState extends State<Blestatelistener> {
  BluetoothConnectionState lastState = BluetoothConnectionState.disconnected;
  @override
  Widget build(BuildContext context) {
    return Consumer<Ble>(
      builder: (context, ble, child) {
        final state = ble.connectionState;
        if (state != lastState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (state == BluetoothConnectionState.connected) {
              showSnackbar(context, "Bluetooth-Scale connected.", context.appColor.success);
            }
            if (state == BluetoothConnectionState.disconnected) {
              showSnackbar(context, "Bluetooth-Scale disconnected.", context.appColor.warning);
            }
            lastState = state;
          });
        }
        return widget.child;
      },
    );
  }
}
