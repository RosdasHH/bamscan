import 'package:auto_size_text/auto_size_text.dart';
import 'package:bamscan/classes/ams.dart';
import 'package:bamscan/classes/ams_spool.dart';
import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/classes/trayslot.dart';
import 'package:bamscan/helper/showsnackbar.dart';
import 'package:bamscan/modals/filament__scanned.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/provider/available_printers.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/tabs/filaments.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:bamscan/utils/color.dart';
import 'package:bamscan/widgets/infocard.dart';
import 'package:bamscan/widgets/nfc_read_page.dart';
import 'package:bamscan/widgets/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
    DeviceCapabilities().checkDevicesCapabilities();
    availableFilaments.getAllSpools();
    amsmapping = await availableFilaments.getFilamentMappingForPrinter(
      int.parse(widget.printerid),
    );
    amsdata = await availablePrinters.getAmsByPrinterId(widget.printerid);
    if (!mounted) return;
    setState(() {
      amsdata = amsdata;
      amsmapping = amsmapping;
    });
  }

  @override
  Widget build(BuildContext context) {
    DeviceCapabilities deviceCapabilities = context.watch<DeviceCapabilities>();
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
                                    ams.isExternalSpool
                                        ? "External Spool"
                                        : "AMS ${ams.id + 1}",
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
                                        double usage = 0.0;
                                        Color color = toFlutterColor(
                                          tray.trayColor,
                                        );
                                        Spool? spool;

                                        if (amsmapping != null) {
                                          for (AmsSpool amsmap in amsmapping!) {
                                            if (amsmap.amsId == ams.id) {
                                              if (amsmap.trayId == tray.id ||
                                                  amsmap.amsId == 255) {
                                                for (Spool filament
                                                    in availableFilaments
                                                        .spools) {
                                                  if (amsmap.spoolId ==
                                                      filament.id) {
                                                    spool = filament;
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                        if (spool != null) {
                                          usage =
                                              (spool.labelWeight -
                                                  spool.weightUsed) /
                                              spool.labelWeight;
                                          color = toFlutterColor(spool.rgba);
                                        }
                                        int amsForIndex = amsdata!.indexOf(ams);
                                        int trayForIndex = ams.tray.indexOf(
                                          tray,
                                        );
                                        TrayType traytype = checkSlotState(
                                          amsForIndex,
                                          trayForIndex,
                                        );
                                        String traytext;
                                        Color traycolor = color;
                                        Color fontcolor = getContrastColor(
                                          color,
                                        );
                                        Color bordercolor = Colors.grey;
                                        switch (traytype) {
                                          case TrayType.spoolLoaded:
                                            traytext = ams.isExternalSpool
                                                ? ""
                                                : (tray.id + 1).toString();
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
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          20,
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    10,
                                                                  ),
                                                              child: Text(
                                                                ams.isExternalSpool
                                                                    ? "Select external spool"
                                                                    : "Select Spool for Slot ${tray.id + 1}",
                                                                style: TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            if (spool !=
                                                                null) ...[
                                                              FilamentCard(
                                                                filament: spool,
                                                                selection: null,
                                                                delete: true,
                                                                deleteCallback: () async {
                                                                  await availableFilaments.unassignSpool(
                                                                    widget
                                                                        .printerid,
                                                                    ams.id
                                                                        .toString(),
                                                                    ams.isExternalSpool
                                                                        ? "0"
                                                                        : tray.id
                                                                              .toString(),
                                                                  );
                                                                  if (!context
                                                                      .mounted) {
                                                                    return;
                                                                  }
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          5,
                                                                    ),
                                                                child:
                                                                    Divider(),
                                                              ),
                                                            ],
                                                            InfoCard(
                                                              title:
                                                                  "Scan QR-Code",
                                                              value: "",
                                                              icon:
                                                                  Icons.qr_code,
                                                              onTap: () {
                                                                scanFilament(
                                                                  ams,
                                                                  tray,
                                                                  availableFilaments
                                                                      .spools,
                                                                );
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                            ),
                                                            if (traytype !=
                                                                    TrayType
                                                                        .noFilament ||
                                                                ams.isExternalSpool)
                                                              InfoCard(
                                                                title:
                                                                    "Select Manually",
                                                                value: "",
                                                                icon: MdiIcons
                                                                    .cursorDefault,
                                                                onTap: () async {
                                                                  final String?
                                                                  spoolId = await showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (
                                                                          BuildContext
                                                                          context,
                                                                        ) {
                                                                          return Dialog(
                                                                            insetPadding: EdgeInsets.all(
                                                                              20,
                                                                            ),
                                                                            child: Padding(
                                                                              padding: EdgeInsets.all(
                                                                                20,
                                                                              ),
                                                                              child: Column(
                                                                                children: [
                                                                                  Text(
                                                                                    ams.isExternalSpool
                                                                                        ? "Select external spool"
                                                                                        : "Select Spool for Slot ${tray.id + 1}",
                                                                                    style: TextStyle(
                                                                                      fontSize: 20,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 15,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: FilamentList(
                                                                                      selection: true,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                  );
                                                                  if (!context
                                                                      .mounted) {
                                                                    return;
                                                                  }
                                                                  if (spoolId ==
                                                                      null) {
                                                                    return;
                                                                  }
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  await availableFilaments.setSlotToSpoolId(
                                                                    widget
                                                                        .printerid,
                                                                    ams.id
                                                                        .toString(),
                                                                    ams.isExternalSpool
                                                                        ? "0"
                                                                        : tray.id
                                                                              .toString(),
                                                                    spoolId
                                                                        .toString(),
                                                                  );
                                                                },
                                                              ),
                                                            if (deviceCapabilities
                                                                .isNfcAvailable)
                                                              InfoCard(
                                                                title:
                                                                    "NFC-Scan",
                                                                value: "",
                                                                icon: MdiIcons
                                                                    .contactlessPayment,
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );

                                                                  nfcreading(
                                                                    ams,
                                                                    tray,
                                                                  );
                                                                },
                                                              ),
                                                          ],
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

  void nfcreading(Ams ams, TraySlot tray) async {
    Spool? spool = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return NfcReadPage();
        },
      ),
    );
    if (spool == null) {
      return;
    }
    return pushToDetailPage(ams, tray, spool);
  }

  void scanFilament(Ams ams, TraySlot slot, List<Spool> spools) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Qrscan(spools: spools)),
    );
    if (res == null && mounted) {
      showSnackbar(context, "No spool found!", context.appColor.error);
      return;
    }
    pushToDetailPage(ams, slot, res);
  }

  void pushToDetailPage(Ams ams, TraySlot slot, Spool spool) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilamentScanned(
          scannedSpool: spool,
          printerid: widget.printerid,
          amsid: ams.id.toString(),
          trayid: slot.id.toString(),
          isExternalSpool: ams.isExternalSpool,
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
