import 'package:bambuscanner/qrscan.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool scannerEnabled = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                child: QrScan(enabled: scannerEnabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
