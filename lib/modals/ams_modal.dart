import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/classes/trayslot.dart';
import 'package:bambuscanner/modals/qrscan_modal.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
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
  List<Ams>? amsdata;
  List<AmsSpool>? amsmapping;

  @override
  void initState() {
    super.initState();
    loadAms();
    refresh();
  }

  void refresh() async {
    while (mounted) {
      await loadAms();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> loadAms() async {
    final availablePrinters = Provider.of<AvailablePrinters>(
      context,
      listen: false,
    );
    final availableFilaments = Provider.of<AvailableFilaments>(
      context,
      listen: false,
    );
    amsmapping = await availableFilaments.getFilamentMappingForPrinter(
      int.parse(widget.printerid),
    );
    amsdata = await availablePrinters.getAmsByPrinterId(widget.printerid);
    setState(() {
      amsdata = amsdata;
      amsmapping = amsmapping;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ams selection")),
      body: amsdata == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (Ams ams in amsdata!)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "AMS ${ams.id + 1}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (TraySlot slot in ams.tray)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SizedBox(
                                    height: 140,
                                    child: Column(
                                      children: [
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: toFlutterColor(
                                              slot.trayColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Material(
                                            color: toFlutterColor(
                                              slot.trayColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        QrscanModal(
                                                          printerid:
                                                              widget.printerid,
                                                          amsid: ams.id
                                                              .toString(),
                                                          trayid: slot.id
                                                              .toString(),
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: SizedBox(
                                                height: 100,
                                                child: Center(
                                                  child: Text(
                                                    (slot.id + 1).toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        if (!checkSpoolAssignment(
                                          ams.tray.indexOf(slot),
                                        ))
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "No Spool!",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
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
            ),
    );
  }

  bool checkSpoolAssignment(int i) {
    for (AmsSpool spool in amsmapping!) {
      if (spool.trayId == i) {
        return true;
      }
    }
    return false;
  }
}
