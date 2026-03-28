import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/classes/trayslot.dart';
import 'package:bambuscanner/modals/filament__scanned_modal.dart';
import 'package:bambuscanner/modals/qrscan_modal.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmsModal extends StatefulWidget {
  const AmsModal({super.key, required this.printerid});

  final String printerid;

  @override
  State<AmsModal> createState() => _AmsModalState();
}

class _AmsModalState extends State<AmsModal> {
  late final Future<List<Ams>> _amsFuture;

  @override
  void initState() {
    super.initState();
    final availablePrinters = Provider.of<AvailablePrinters>(
      context,
      listen: false,
    );
    _amsFuture = availablePrinters.getAmsByPrinterId(widget.printerid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ams selection")),
      body: FutureBuilder<List<Ams>>(
        future: _amsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final List<Ams> amslist = snapshot.data ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (Ams ams in amslist)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Überschrift für jedes AMS
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "AMS ${ams.id}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (TraySlot tray in ams.tray)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: toFlutterColor(tray.trayColor),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Material(
                                      color: toFlutterColor(tray.trayColor),
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () async {
                                          print("Puhsing");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => QrscanModal(
                                                printerid: widget.printerid,
                                                amsid: ams.id.toString(),
                                                trayid: tray.id.toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 100,
                                          child: Center(
                                            child: Text(
                                              (tray.id + 1).toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 20), // Abstand zwischen AMS-Gruppen
                      ],
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
