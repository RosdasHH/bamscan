import 'package:bamscan/classes/ams.dart';
import 'package:bamscan/classes/printer.dart';
import 'package:bamscan/classes/printer_status.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/provider/available_printers.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/services/globals.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:bamscan/widgets/ams.dart';
import 'package:bamscan/widgets/mjpeg_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class PrinterView extends StatefulWidget {
  const PrinterView({super.key, required this.printer});
  final Printer printer;

  @override
  State<PrinterView> createState() => _PrinterViewState();
}

class _PrinterViewState extends State<PrinterView> {
  List<Ams>? allAms;
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
    final AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
    DeviceCapabilities().checkDevicesCapabilities();
    availableFilaments.getAllSpools();
    allAms = await availableFilaments.getAllAms(widget.printer);
    if (!mounted) return;
    setState(() {
      allAms = allAms;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AvailablePrinters availablePrinters = context.watch<AvailablePrinters>();
    final Printer printer = availablePrinters.printers.where((printer) => printer.id == widget.printer.id).first;
    final PrinterStatus? pStatus = printer.status;
    List<Map<String, String>> statusbar = [
      {"Status": pStatus?.state ?? ""},
      {"Progress": "${pStatus?.progress ?? 0}%"},
      {"Layer": "${pStatus?.layerNum}/${pStatus?.totalLayers}"},
      {"Time": pStatus?.remainingTime == 0 ? "--:--" : (pStatus?.remainingTime).toString()},
    ];
    //Nozzle
    final currentNozzleTemp = pStatus?.temperatures.nozzle.toStringAsFixed(1) ?? "";
    final targetNozzleTemp = pStatus?.temperatures.nozzleTarget.toStringAsFixed(1) ?? "";
    final nozzleTempsDisplay = "$currentNozzleTemp°C/$targetNozzleTemp°C";
    //Bed
    final currentBedTemp = pStatus?.temperatures.bed.toStringAsFixed(1) ?? "";
    final targetbedTemp = pStatus?.temperatures.bedTarget.toStringAsFixed(1) ?? "";
    final bedTempsDisplay = "$currentBedTemp°C/$targetbedTemp°C";

    final int rssi = pStatus?.rssi ?? 0;
    final rssiColor = rssi > -67
        ? context.appColor.success
        : rssi > 75
        ? context.appColor.warning
        : context.appColor.error;
    final rssiDisplay = "${rssi.toString()}dBm";
    StorageService storageService = context.read<StorageService>();
    String mjpegUrl = "${storageService.getString(StorageService.kBambuddyUrl)}${Globals.apinamespace}/printers/${printer.id}/camera/stream";
    return Scaffold(
      appBar: AppBar(title: Text(printer.name)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MjpegView(url: mjpegUrl),
                ),
                SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          for (Map<String, String> status in statusbar) ...[
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(status.keys.first, style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                                  Text(status.values.first),
                                ],
                              ),
                            ),
                            if (statusbar.last != status) VerticalDivider(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (printer.status?.coverUrl != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: IntrinsicHeight(child: Row(children: [if (printer.status?.coverUrl != null) Image.network(printer.status!.coverUrl!, height: 64, width: 64)])),
                    ),
                  ),
                SizedBox(height: 5),
                MasonryGridView.extent(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final List<Widget> cards = [
                      VerticalCard(
                        titleWidgets: [
                          Icon(Icons.device_thermostat_outlined),
                          SizedBox(width: 10),
                          Text("Temperatures", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                        widgets: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(MdiIcons.printer3DNozzle),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nozzle", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                                  Text(nozzleTempsDisplay),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(MdiIcons.radiator),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Bed", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                                  Text(bedTempsDisplay),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      VerticalCard(
                        titleWidgets: [
                          Icon(Icons.wifi),
                          SizedBox(width: 10),
                          Text("Connection", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                        widgets: [
                          Text("IP-Adress", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text(printer.ipAddress),
                          SizedBox(height: 2),
                          Text("Wifi-Signal", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text(rssiDisplay, style: TextStyle(color: rssiColor)),
                          SizedBox(height: 2),
                          Text("IP-Cam", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text((pStatus?.ipCam.toString()) ?? "", style: TextStyle(color: (pStatus?.ipCam ?? false) ? context.appColor.success : context.appColor.error)),
                          Text("SD-Card", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text((pStatus?.sdcard.toString()) ?? "", style: TextStyle(color: (pStatus?.sdcard ?? false) ? context.appColor.success : context.appColor.error)),
                        ],
                      ),
                      VerticalCard(
                        titleWidgets: [
                          Icon(MdiIcons.printer3D),
                          SizedBox(width: 10),
                          Text("Machine", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                        widgets: [
                          Text("Model", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text(printer.model),
                          SizedBox(height: 2),
                          Text("Serial Number", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text(printer.serialNumber),
                          SizedBox(height: 2),
                          Text("Firmware", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text((pStatus?.firmwareVersion) ?? ""),
                          Text("Print hours", style: TextStyle(color: context.appColor.secondaryText, fontSize: 12)),
                          Text("${printer.printHoursOffset.toString()}h"),
                        ],
                      ),
                    ];
                    return cards[index];
                  },
                ),
                SizedBox(height: 5),
                if (allAms != null)
                  for (Ams ams in allAms!) AmsSelection(printer: printer, ams: ams),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VerticalCard extends StatelessWidget {
  const VerticalCard({super.key, required this.widgets, required this.titleWidgets});
  final List<Widget> widgets;
  final List<Widget> titleWidgets;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [for (Widget titleWidget in titleWidgets) titleWidget]),
              Divider(),
              for (Widget widget in widgets) widget,
            ],
          ),
        ),
      ),
    );
  }
}
