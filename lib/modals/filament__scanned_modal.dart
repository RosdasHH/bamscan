import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/classes/trayslot.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/widgets/filament_view.dart';
import 'package:bambuscanner/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilamentScannedModal extends StatefulWidget {
  const FilamentScannedModal({
    super.key,
    required this.scannedSpool,
    required this.printerid,
    required this.amsid,
    required this.trayid,
  });
  final Spool scannedSpool;
  final String printerid;
  final String amsid;
  final String trayid;

  @override
  State<FilamentScannedModal> createState() => _FilamentScannedModalState();
}

class _FilamentScannedModalState extends State<FilamentScannedModal> {
  List<AmsSpool>? mappings;
  AmsSpool? spoolAssignment;
  bool loadingAssignments = true;
  //Waiting for spool to be loaded before assigning filament
  bool? spoolLoaded;

  @override
  void initState() {
    super.initState();
    _loadMappings();
  }

  Future<void> _loadMappings() async {
    final availableFilaments = Provider.of<AvailableFilaments>(
      context,
      listen: false,
    );
    mappings = await availableFilaments.getAllFilamentMappings();
    if (mappings == null) return;
    //Slot data if spool is already assigned
    for (AmsSpool mapping in mappings!) {
      if (mapping.spoolId == widget.scannedSpool.id) {
        spoolAssignment = mapping;
      }
    }
    setState(() {
      mappings = mappings;
      spoolAssignment = spoolAssignment;
      loadingAssignments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableFilaments = context.watch<AvailableFilaments>();
    if (loadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.popUntil(
              context,
              (route) => route.settings.name == "ams",
            );
          });
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("Assigning Spool to Slot")),
          body: LoadingScreen(
            loading: spoolLoaded == false,
            loadingMessage: "Waiting for spool insertion...",
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilamentViewScreen(spool: widget.scannedSpool),
                    ),
                  ],
                ),
                if (spoolAssignment != null)
                  Row(
                    children: [
                      if (spoolAssignment?.trayId.toString() == widget.trayid &&
                          spoolAssignment?.printerId.toString() ==
                              widget.printerid &&
                          spoolAssignment?.amsId.toString() == widget.amsid)
                        Text(
                          "This spool is already assigned to this Slot.",
                          overflow: TextOverflow.clip,
                          style: TextStyle(color: Colors.red),
                        )
                      else
                        Text(
                          "This spool is alredy assigned on: ${spoolAssignment!.printerName}, AMS_ID: ${spoolAssignment!.amsId}, TRAY_ID: ${spoolAssignment!.trayId}",
                          overflow: TextOverflow.clip,
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              setState(() {
                spoolLoaded = false;
              });
              while (spoolLoaded == false) {
                AvailablePrinters printers = AvailablePrinters();
                final List<Ams> allams = await printers.getAmsByPrinterId(
                  widget.printerid,
                );
                for (Ams ams in allams) {
                  if (ams.id.toString() == widget.amsid) {
                    for (TraySlot tray in ams.tray) {
                      if (tray.id.toString() == widget.trayid) {
                        if (tray.trayColor != "" &&
                            tray.trayType != "" &&
                            tray.trayInfoIdx != "") {
                          setState(() {
                            spoolLoaded = true;
                          });
                        }
                      }
                    }
                  }
                }

                await Future.delayed(Duration(milliseconds: 500));
              }
              bool configured = await availableFilaments.setSlotToSpoolId(
                widget.printerid,
                widget.amsid,
                widget.trayid,
                widget.scannedSpool.id.toString(),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: configured
                      ? Text("Spool assigned")
                      : Text("Spool NOT assigned"),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.popUntil(
                context,
                (route) => route.settings.name == "ams",
              );
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.check),
          ),
        ),
      );
    }
  }
}
