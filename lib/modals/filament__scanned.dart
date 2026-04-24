import 'package:bamscan/classes/ams.dart';
import 'package:bamscan/classes/ams_spool.dart';
import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/classes/trayslot.dart';
import 'package:bamscan/helper/showsnackbar.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/provider/available_printers.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:bamscan/widgets/filament_view.dart';
import 'package:bamscan/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilamentScanned extends StatefulWidget {
  const FilamentScanned({super.key, required this.scannedSpool, required this.printerid, required this.amsid, required this.trayid, this.isExternalSpool = false});
  final Spool scannedSpool;
  final String printerid;
  final String amsid;
  final String trayid;
  final bool isExternalSpool;

  @override
  State<FilamentScanned> createState() => _FilamentScannedModal();
}

class _FilamentScannedModal extends State<FilamentScanned> {
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
    final availableFilaments = Provider.of<AvailableFilaments>(context, listen: false);
    mappings = await availableFilaments.getAllFilamentMappings();
    if (mappings == null) return;
    //Slot data if spool is already assigned
    for (AmsSpool mapping in mappings!) {
      if (mapping.spoolId == widget.scannedSpool.id) {
        spoolAssignment = mapping;
      }
    }

    if (!mounted) return;
    if (spoolAssignment != null) {
      showSnackbar(context, "This spool is already assigned to a slot.", context.appColor.error);
    }

    setState(() {
      mappings = mappings;
      spoolAssignment = spoolAssignment;
      loadingAssignments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableFilaments = context.read<AvailableFilaments>();
    if (loadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.popUntil(context, (route) => route.settings.name == "ams");
          });
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("Assigning Spool to Slot")),
          body: LoadingScreen(
            loading: spoolLoaded == false,
            loadingMessage: "Waiting for spool insertion...",
            child: Column(
              children: [
                Expanded(child: FilamentViewScreen(spool: widget.scannedSpool)),
                //if (spoolAssignment != null)
                //  Row(
                //    children: [
                //      if (spoolAssignment?.trayId.toString() == widget.trayid &&
                //          spoolAssignment?.printerId.toString() ==
                //              widget.printerid &&
                //          spoolAssignment?.amsId.toString() == widget.amsid)
                //        Text(
                //          "This spool is already assigned to this Slot.",
                //          overflow: TextOverflow.clip,
                //          style: TextStyle(color: Colors.red),
                //        )
                //      else
                //        Text(
                //          "This spool is already assigned on: ${spoolAssignment!.printerName}, AMS_ID: ${spoolAssignment!.amsId}, TRAY_ID: ${spoolAssignment!.trayId}",
                //          overflow: TextOverflow.clip,
                //          style: TextStyle(color: Colors.red),
                //        ),
                //    ],
                //  ),
              ],
            ),
          ),
          floatingActionButton: spoolLoaded != false && spoolAssignment == null
              ? FloatingActionButton(
                  onPressed: () async {
                    if (!widget.isExternalSpool) {
                      setState(() {
                        spoolLoaded = false;
                      });
                    }
                    while (spoolLoaded == false) {
                      AvailablePrinters printers = AvailablePrinters();
                      final List<Ams> allams = await printers.getAmsByPrinterId(widget.printerid);
                      for (Ams ams in allams) {
                        if (ams.id.toString() == widget.amsid) {
                          for (TraySlot tray in ams.tray) {
                            if (tray.id.toString() == widget.trayid) {
                              if (tray.trayColor != "" && tray.trayType != "" && tray.trayInfoIdx != "") {
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
                      widget.isExternalSpool ? "0" : widget.trayid,
                      widget.scannedSpool.id.toString(),
                    );
                    if (!context.mounted) return;
                    showSnackbar(context, configured ? "Spool assigned" : "Spool NOT assigned", null);
                    Navigator.popUntil(context, (route) => route.settings.name == "ams");
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.check),
                )
              : null,
        ),
      );
    }
  }
}
