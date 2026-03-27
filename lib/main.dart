import 'package:bambuscanner/api.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/modals/filament__scanned_modal.dart';
import 'package:bambuscanner/qrscan.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool scannerEnabled = false;
  String? scannedCode;

  Spool? scannedSpool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  scannerEnabled = !scannerEnabled;
                });
              },
              child: Text(scannerEnabled ? "Scanner AUS" : "Scanner AN"),
            ),
            SizedBox(
              height: 300,
              child: QrScan(
                enabled: scannerEnabled,
                scanDataCallback: (callback) async {
                  final spool = await getSpoolById(callback);

                  if (!mounted) return;

                  setState(() {
                    scannedCode = callback;
                    scannerEnabled = false;
                    scannedSpool = spool;
                  });
                  if (!context.mounted || scannedSpool == null) return;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return FilamentScannedModal(scannedSpool: scannedSpool!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
