import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMappings();
  }

  Future<void> _loadMappings() async {
    mappings = await getAllFilamentMappings();
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
    if (loadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          Navigator.popUntil(context, (route) => route.settings.name == "ams");
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("Scanned spool")),
          body: Column(
            children: [
              Row(
                children: [Text("Material: ${widget.scannedSpool.material}")],
              ),
              Row(children: [Text("Subtype: ${widget.scannedSpool.subtype}")]),
              Row(
                children: [
                  Text("Color Name: ${widget.scannedSpool.colorName}"),
                ],
              ),
              Row(children: [Text("Brand: ${widget.scannedSpool.brand}")]),
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: toFlutterColor(widget.scannedSpool.rgba),
                    ),
                    child: SizedBox.square(dimension: 20),
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
                )
              else
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        bool configured = await setSlotToSpoolId(
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
                      child: const Text("Apply"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
  }
}
