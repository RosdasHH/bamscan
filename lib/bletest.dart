import 'dart:io';

import 'package:bamscan/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLE extends StatefulWidget {
  const BLE({super.key});

  @override
  State<BLE> createState() => _BLEState();
}

class _BLEState extends State<BLE> {
  List<ScanResult> bleResults = [];

  @override
  void initState() {
    super.initState();
    fetchBleDevices();
  }

  void fetchBleDevices() async {
    var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      if (state == BluetoothAdapterState.on) {
        //Bluetooth is enabled
        print("Bluetooth is enabled!");
        print("Proceeding..");
        // listen to scan results
        // Note: `onScanResults` clears the results between scans. You should use
        //  `scanResults` if you want the current scan results *or* the results from the previous scan.
        var subscription = FlutterBluePlus.onScanResults.listen((results) {
          if (results.isNotEmpty) {
            ScanResult r = results.last;
            setState(() {
              if (!bleResults.any((d) => d.device.remoteId == r.device.remoteId)) {
                bleResults.add(r);
              }
            });
          }
        }, onError: (e) => print(e));

        FlutterBluePlus.cancelWhenScanComplete(subscription);

        // Wait for Bluetooth enabled & permission granted
        // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
        await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

        // Start scanning w/ timeout
        // Optional: use `stopScan()` as an alternative to timeout
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 3));

        // wait for scanning to stop
        await FlutterBluePlus.isScanning.where((val) => val == false).first;
        subscription.cancel();
        print("Scan completed");
      } else {
        //Bluetooth is disabled
        print("Bluetooth is disabled");
        if (Platform.isAndroid && !kIsWeb) {
          await FlutterBluePlus.turnOn();
        } else {
          print("Please turn on Bluetooth");
        }
      }
    });
  }

  void connect(ScanResult res) async {
    print(res.advertisementData.manufacturerData);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Scan")),
      body: Column(
        children: [
          for (ScanResult res in bleResults) ...[
            if (res.device.advName != "")
              Button(
                onPressed: () {
                  connect(res);
                },
                child: Text(res.device.advName),
              ),
          ],
        ],
      ),
    );
  }
}
