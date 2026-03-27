import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/printers.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AvailablePrinters(),
      child: MaterialApp(home: const MyApp()),
    ),
  );
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
      body: SafeArea(child: Column(children: [Printers()])),
      //showDialog(
      //  context: context,
      //  builder: (BuildContext context) {
      //    return FilamentScannedModal(scannedSpool: scannedSpool!);
      //  },
      //);
    );
  }
}
