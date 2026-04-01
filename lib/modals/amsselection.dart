import 'package:auto_size_text/auto_size_text.dart';
import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/classes/slot_preset.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/classes/trayslot.dart';
import 'package:bambuscanner/modals/qrscan_modal.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:bambuscanner/widgets/infocard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmsSelection extends StatefulWidget {
  const AmsSelection({super.key, required this.printerid});

  final String printerid;

  @override
  State<AmsSelection> createState() => _AmsSelectionState();
}

class _AmsSelectionState extends State<AmsSelection> {
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
    availableFilaments.getAllSpools();
    amsmapping = await availableFilaments.getFilamentMappingForPrinter(
      int.parse(widget.printerid),
    );
    amsdata = await availablePrinters.getAmsByPrinterId(widget.printerid);
    if (amsdata != null && amsdata!.isNotEmpty) {
      amsdata!.add(amsdata![0]);
      amsdata!.add(amsdata![0]);
      amsdata!.add(amsdata![0]);
    }

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
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (Ams ams in amsdata!)
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 5),
                                  Text(
                                    "AMS ${ams.id + 1}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  for (TraySlot tray in ams.tray) ...[
                                    Builder(
                                      builder: (context) {
                                        AvailableFilaments availableFilaments =
                                            context.read<AvailableFilaments>();
                                        TrayType traytype = checkSlotState(
                                          amsdata!.indexOf(ams),
                                          ams.tray.indexOf(tray),
                                        );
                                        String traytext;
                                        Color traycolor = toFlutterColor(
                                          tray.trayColor,
                                        );
                                        Color fontcolor = getContrastColor(
                                          toFlutterColor(tray.trayColor),
                                        );
                                        Color bordercolor = Colors.grey;
                                        double usage = 0.0;
                                        switch (traytype) {
                                          case TrayType.spoolLoaded:
                                            traytext = (tray.id + 1).toString();
                                            break;
                                          case TrayType.noSpool:
                                            traytext = "No Spool!";
                                            fontcolor = context.appColor.error;
                                            bordercolor =
                                                context.appColor.error;
                                            break;
                                          case TrayType.noFilament:
                                            traytext = "X";
                                            break;
                                        }
                                        if (amsmapping != null) {
                                          for (AmsSpool amsmapping
                                              in amsmapping!) {
                                            if (amsmapping.trayId == tray.id) {
                                              for (Spool spool
                                                  in availableFilaments
                                                      .spools) {
                                                if (amsmapping.spoolId ==
                                                    spool.id) {
                                                  usage =
                                                      (spool.labelWeight -
                                                          spool.weightUsed) /
                                                      spool.labelWeight;
                                                }
                                              }
                                            }
                                          }
                                        }
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: SizedBox(
                                                height: 100,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1,
                                                      color: bordercolor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    color: traycolor,
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          if (traytype ==
                                                              TrayType
                                                                  .spoolLoaded)
                                                            CircularProgressIndicator(
                                                              color: fontcolor,
                                                              value: usage,
                                                              backgroundColor:
                                                                  fontcolor
                                                                      .withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                            ),
                                                          AutoSizeText(
                                                            traytext,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              color: fontcolor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                scanFilament(ams, tray);
                                              },
                                              onLongPress: () async {
                                                AvailableFilaments
                                                availableFilaments = context
                                                    .read<AvailableFilaments>();
                                                SlotPreset preset =
                                                    await availableFilaments
                                                        .getPreset(
                                                          widget.printerid,
                                                          ams.id.toString(),
                                                          tray.id.toString(),
                                                        );
                                                if (!context.mounted) return;
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      insetPadding:
                                                          EdgeInsets.all(25),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          10,
                                                        ),
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                      10,
                                                                    ),
                                                                child: Text(
                                                                  "Tray Info",
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                      ),
                                                                ),
                                                              ),
                                                              InfoCard(
                                                                title: "Preset",
                                                                value: preset
                                                                    .presetName,
                                                                icon: Icons.abc,
                                                              ),
                                                              InfoCard(
                                                                title:
                                                                    "Material",
                                                                value: tray
                                                                    .trayType,
                                                                icon: Icons.abc,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  void scanFilament(Ams ams, TraySlot slot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrscanModal(
          printerid: widget.printerid,
          amsid: ams.id.toString(),
          trayid: slot.id.toString(),
        ),
      ),
    );
  }

  TrayType checkSlotState(int amsi, int trayi) {
    for (AmsSpool spool in amsmapping!) {
      if (amsdata![amsi].tray[trayi].trayInfoIdx == "") {
        return TrayType.noFilament;
      } else if (spool.trayId == trayi) {
        return TrayType.spoolLoaded;
      }
    }
    return TrayType.noSpool;
  }
}

enum TrayType {
  //Spool loaded, no spool loaded, no physical loaded filament
  spoolLoaded,
  noSpool,
  noFilament,
}
