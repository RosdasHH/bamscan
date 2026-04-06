import 'package:bambuscanner/classes/printer.dart';
import 'package:bambuscanner/modals/amsselection.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/tabs/offline.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/widgets/badgeCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Printers extends StatefulWidget {
  const Printers({super.key});

  @override
  State<Printers> createState() => _PrintersState();
}

class _PrintersState extends State<Printers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Printers")),
      body: PrinterList(),
    );
  }
}

class PrinterList extends StatefulWidget {
  const PrinterList({super.key});

  @override
  State<PrinterList> createState() => _PrinterListState();
}

class _PrinterListState extends State<PrinterList> {
  final storageservice = StorageService();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    storageservice.loadFromStorage();
    if (!mounted) return;
    refresh();
  }

  void refresh() async {
    while (mounted) {
      await fetch();
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Future<void> fetch() async {
    final AvailablePrinters availablePrinters = context
        .read<AvailablePrinters>();
    if (!availablePrinters.printersSet) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await availablePrinters.fetchPrinters();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final printers = context.watch<AvailablePrinters>().printers;
    final storage = context.read<StorageService>();
    final ApiService apiService = context.watch<ApiService>();
    String? configerror;
    if (!apiService.reachable) return Offline();

    if (storage.bambuddyUrl == "") {
      configerror = "Please enter the Bambuddy Url in the Settings tab.";
    } else if (storage.xapitoken == "") {
      configerror = "Please enter your Bambuddy API Token in the Settings tab.";
    }
    if (configerror != null) return Center(child: Text(configerror));
    if (apiService.error != null) {
      return Center(child: Text(apiService.error.toString()));
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          children: [
            if (printers.isEmpty) Center(child: Text("No printers available.")),
            for (Printer printer in printers)
              Builder(
                builder: (BuildContext context) {
                  final status = printer.status;
                  if (status == null) return SizedBox.shrink();
                  final String connected = status.connected
                      ? "Connected"
                      : "Not connected";
                  final Color connectedColor = status.connected
                      ? context.appColor.success
                      : context.appColor.error;
                  final double progress = status.progress / 100;
                  final String state = status.state;
                  final stateColor = state == "FAILED"
                      ? context.appColor.error
                      : state == "FINISH"
                      ? context.appColor.success
                      : state == "PREPARE"
                      ? Colors.orange
                      : state == "RUNNING"
                      ? Colors.purple
                      : Colors.blue;
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: "ams"),
                            builder: (context) =>
                                AmsSelection(printerid: printer.id.toString()),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          spacing: 5,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: SizedBox.square(
                                dimension: 75,
                                child: Image.network(
                                  "${storage.bambuddyUrl}${Globals.imagesnamespace}${printer.model.replaceAll(" ", "").toLowerCase()}.png",
                                  errorBuilder: (context, error, stackTrace) =>
                                      SizedBox.expand(),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    printer.name,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    printer.model,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      BadgeCard(
                                        text: connected,
                                        color: connectedColor,
                                      ),
                                      BadgeCard(text: state, color: stateColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Stack(
                                alignment: AlignmentGeometry.center,
                                children: [
                                  SizedBox.square(
                                    dimension: 50,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 7,
                                      value: progress,
                                    ),
                                  ),
                                  Text(
                                    "${(progress * 100).toInt()}%",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class IconWithCicle extends StatelessWidget {
  const IconWithCicle({super.key, required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Icon(icon, color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}

class CardWithoutMat extends StatelessWidget {
  final Widget child;

  const CardWithoutMat({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColor.base3,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
