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
import 'package:bamscan/widgets/button.dart';
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
      {"Time": pStatus?.remainingTime == 0 ? "--:--" : "${pStatus?.remainingTime}m"},
    ];
    final printerState = printer.status?.state ?? "";
    final isPrinting = !(printerState == "IDLE" || printerState == "FINISH" || printerState == "FAILED");

    final currentPrintName = printer.status?.currentPrint != "" ? printer.status?.currentPrint ?? "Ready to print" : "Ready to print";
    final currentTask = printer.status?.currentTask != "" ? printer.status?.currentTask ?? printerState : "ERROR";

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
                                  Text(
                                    status.keys.first,
                                    style: TextStyle(color: context.appColor.secondaryText, fontSize: 12, overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(status.values.first, style: TextStyle(overflow: TextOverflow.ellipsis)),
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
                SizedBox(height: 5),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 10,
                              children: [
                                CoverUrlWithProgress(printer: printer),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentPrintName,
                                        style: TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(currentTask, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //if (!isPrinting)
                          //  Row(
                          //    children: [Button(onPressed: () {}, color: context.appColor.success, child: Text("Start"))],
                          //  )
                          SizedBox(width: 5),
                          if (isPrinting)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                if (printerState == "PAUSE")
                                  Button(onPressed: () => printer.resumePrint(), color: context.appColor.info, child: Text("Resume"))
                                else
                                  Button(onPressed: () => printer.pausePrint(), color: context.appColor.warning, child: Text("Pause")),
                                Button(onPressed: () => printer.stopPrint(), color: context.appColor.error, child: Text("Stop")),
                              ],
                            ),
                        ],
                      ),
                    ),
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
                          Text("${printer.maintenance.currentHours.toStringAsFixed(0)}h"),
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

class PartialBorderPainter extends CustomPainter {
  final double progress;
  final double radius;
  final Color color;

  PartialBorderPainter({required this.progress, this.radius = 20, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const strokeWidth = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    final r = radius;
    final path = Path();
    path.moveTo(w / 2, strokeWidth / 2);
    path.lineTo(w - r, strokeWidth / 2);
    path.arcToPoint(Offset(w - strokeWidth / 2, r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(w - strokeWidth / 2, h - r);
    path.arcToPoint(Offset(w - r, h - strokeWidth / 2), radius: Radius.circular(r), clockwise: true);
    path.lineTo(r, h - strokeWidth / 2);
    path.arcToPoint(Offset(strokeWidth / 2, h - r), radius: Radius.circular(r), clockwise: true);
    path.lineTo(strokeWidth / 2, r);
    path.arcToPoint(Offset(r, strokeWidth / 2), radius: Radius.circular(r), clockwise: true);
    path.lineTo(w / 2, strokeWidth / 2);
    final metric = path.computeMetrics().first;
    final partialPath = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(partialPath, paint);
  }

  @override
  bool shouldRepaint(covariant PartialBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.radius != radius;
  }
}

class CoverUrlWithProgress extends StatefulWidget {
  const CoverUrlWithProgress({super.key, required this.printer});
  final Printer printer;

  @override
  State<CoverUrlWithProgress> createState() => _CoverUrlWithProgressState();
}

class _CoverUrlWithProgressState extends State<CoverUrlWithProgress> {
  @override
  Widget build(BuildContext context) {
    final progress = (widget.printer.status?.progress ?? 0) / 100;

    return CustomPaint(
      foregroundPainter: PartialBorderPainter(progress: progress, radius: 15, color: context.appColor.primary),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(15),
        child: SizedBox.square(
          dimension: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(color: context.appColor.base1, borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: widget.printer.status?.coverUrl != null
                  ? Image.network(
                      widget.printer.status!.coverUrl!,
                      height: 64,
                      width: 64,
                      errorBuilder: (context, error, stackTrace) {
                        return GenericPrintJobIcon();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return GenericPrintJobIcon();
                      },
                    )
                  : GenericPrintJobIcon(),
            ),
          ),
        ),
      ),
    );
  }
}

class GenericPrintJobIcon extends StatelessWidget {
  const GenericPrintJobIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(MdiIcons.cubeOutline, color: context.appColor.base3);
  }
}
