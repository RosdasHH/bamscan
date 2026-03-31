import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:bambuscanner/utils/parse_note.dart';
import 'package:bambuscanner/widgets/button.dart';
import 'package:bambuscanner/widgets/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FilamentView extends StatefulWidget {
  const FilamentView({super.key, required this.spool, required this.editable});
  final Spool spool;
  final bool editable;

  @override
  State<FilamentView> createState() => FilamentViewState();
}

class FilamentViewState extends State<FilamentView> {
  @override
  Widget build(BuildContext context) {
    final Color filamentColor = toFlutterColor(widget.spool.rgba);
    final Color filamentConformTextColor = getContrastColor(filamentColor);
    final spool = context.watch<AvailableFilaments>().spools.firstWhere(
      (s) => s.id == widget.spool.id,
    );

    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: toFlutterColor(spool.rgba),
                      ),
                      child: Center(
                        child: Text(
                          spool.material,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: filamentConformTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            InfoCard(
              icon: Icons.abc,
              title: "Color Name:",
              value: spool.colorName,
            ),
            InfoCard(
              icon: Icons.precision_manufacturing,
              title: "Brand:",
              value: spool.brand,
            ),
            InfoCard(
              icon: MdiIcons.weight,
              title: "Weight:",
              value:
                  "${spool.labelWeight - spool.weightUsed}/${spool.labelWeight}",
              spoolColor: context.appColor.primary,
              progress:
                  (spool.labelWeight - spool.weightUsed) / spool.labelWeight,
            ),
            InfoCard(
              icon: Icons.qr_code,
              title: "Assigned QR-Code:",
              value: spool.qrcode ?? "None",
              more: QRCodeMore(spool: spool),
            ),
          ],
        ),
      ),
    );
  }
}

class FilamentViewScreen extends StatefulWidget {
  const FilamentViewScreen({
    super.key,
    required this.spool,
    this.editable = false,
    this.useScaffold = false,
  });
  final Spool spool;
  final bool editable;
  final bool useScaffold;

  @override
  State<FilamentViewScreen> createState() => FilamentViewScreenState();
}

class FilamentViewScreenState extends State<FilamentViewScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.useScaffold) {
      return Scaffold(
        appBar: AppBar(title: Text("Spool")),
        body: FilamentView(spool: widget.spool, editable: widget.editable),
      );
    } else {
      return FilamentView(spool: widget.spool, editable: widget.editable);
    }
  }
}

class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.progress,
    this.spoolColor,
    this.more,
  });
  final IconData icon;
  final String title;
  final String? value;
  final double? progress;
  final Color? spoolColor;
  final Widget? more;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.value == null) return SizedBox.shrink(); //Nothing
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Card(
              child: InkWell(
                onTap: widget.more != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => widget.more!),
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 70,
                  child: Stack(
                    children: [
                      if (widget.progress != null && widget.spoolColor != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: widget.progress!.clamp(0.0, 1.0),
                              child: SizedBox.expand(
                                child: Container(
                                  color: widget.spoolColor!.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: SizedBox(
                          height: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      widget.icon,
                                      color: context.appColor.primary,
                                    ),
                                  ),
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(widget.value!),
                                  if (widget.more != null)
                                    Icon(Icons.chevron_right_rounded),
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
            ),
          ),
        ),
      ],
    );
  }
}

class QrScanAssignQrCode extends StatefulWidget {
  const QrScanAssignQrCode({super.key, required this.scanDataCallback});
  final Function(String) scanDataCallback;

  @override
  State<QrScanAssignQrCode> createState() => _QrScanAssignQrCode();
}

class _QrScanAssignQrCode extends State<QrScanAssignQrCode> {
  bool scanenabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR-Code")),
      body: QrScan(
        enabled: scanenabled,
        scanDataCallback: (spoolid) async {
          if (spoolid != null) widget.scanDataCallback(spoolid);
          setState(() {
            scanenabled = false;
          });

          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class QRCodeMore extends StatefulWidget {
  const QRCodeMore({super.key, required this.spool});
  final Spool spool;

  @override
  State<QRCodeMore> createState() => _QRCodeMoreState();
}

class _QRCodeMoreState extends State<QRCodeMore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR-Code")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.grey),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: widget.spool.qrcode != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: QrImageView(
                                  data: widget.spool.qrcode!,
                                  version: QrVersions.auto,
                                  size: 250,
                                  backgroundColor: Colors.transparent,
                                ),
                              )
                            : SizedBox.square(dimension: 320),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Button(
                    onPressed: () {
                      assignQrCode();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [Icon(Icons.add), Text("Assign QR-Code")],
                    ),
                  ),
                  Button(
                    onPressed: () {
                      unassignQrCode();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [Icon(Icons.remove), Text("Unassign QR-Code")],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void unassignQrCode() async {
    final availableFilaments = context.read<AvailableFilaments>();
    final bool res = await deleteQrCodeReq(context, widget.spool);
    if (res) print("Deleted successfully");
    await availableFilaments.getAllSpools();
    if (!mounted) return;
    Navigator.pop(context);
  }

  void assignQrCode() async {
    final availableFilaments = context.read<AvailableFilaments>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: "qrscanassign"),
        builder: (context) => QrScanAssignQrCode(
          scanDataCallback: (scannedqrid) async {
            final bool success = await addQrCodeReq(
              context,
              widget.spool,
              scannedqrid,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? "Successfully assigned QR-Code to this Spool!"
                      : "Could NOT assign this QR-Code to the spool!",
                ),
                backgroundColor: success == true
                    ? context.appColor.success
                    : context.appColor.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
    await availableFilaments.getAllSpools();
  }
}
