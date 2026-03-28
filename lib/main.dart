import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/printers.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/settings.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvailablePrinters()),
        ChangeNotifierProvider(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: "BamScan",
        theme: AppTheme().dark,
        home: const MyApp(),
      ),
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
  int currentPageIndex = 0;

  final List<Widget> pages = [Printers(), Settings()];
  final List<String> titles = ["Printers", "Settings"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[currentPageIndex])),
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.print), label: "Printers"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      body: SafeArea(child: pages[currentPageIndex]),
      //showDialog(
      //  context: context,
      //  builder: (BuildContext context) {
      //    return FilamentScannedModal(scannedSpool: scannedSpool!);
      //  },
      //);
    );
  }
}
