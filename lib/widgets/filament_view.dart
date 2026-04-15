import 'package:auto_size_text/auto_size_text.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/helper/showsnackbar.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/utils/ams_number_letter.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:bambuscanner/utils/parse_note.dart';
import 'package:bambuscanner/widgets/button.dart';
import 'package:bambuscanner/widgets/infocard.dart';
import 'package:bambuscanner/widgets/qrscan.dart';
import 'package:bambuscanner/widgets/textinput.dart';
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
    final spools = context.watch<AvailableFilaments>();
    final spool = spools.spools.firstWhere(
      (s) => s.id == widget.spool.id,
      orElse: () => widget.spool,
    );
    final Color filamentColor = toFlutterColor(spool.rgba);
    final Color filamentConformTextColor = getContrastColor(filamentColor);

    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: SingleChildScrollView(
        child: Column(
          spacing: 8,
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
            if (spool.assignment != null)
              Chip(
                label: Text(
                  "${spool.assignment!.printerName} ${amsIdToLetter(spool.assignment!.amsId)}${spool.assignment!.trayId + 1}",
                ),
                backgroundColor: Colors.purple.withValues(alpha: 0.3),
              ),

            InfoCard(
              icon: Icons.color_lens,
              title: "Color Name",
              value: spool.colorName,
              apiname: "color_name",
              spool: spool,
            ),
            InfoCard(
              icon: MdiIcons.printer3DNozzle,
              title: "Material",
              value: spool.material,
              apiname: "material",
              spool: spool,
            ),
            InfoCard(
              icon: MdiIcons.factoryIcon,
              title: "Brand",
              value: spool.brand,
                            apiname: "brand",
              spool: spool,
            ),
            InfoCard(
              icon: MdiIcons.shape,
              title: "Subtype",
              value: spool.subtype,
                            apiname: "subtype",
              spool: spool,
            ),
            InfoCard(
              icon: MdiIcons.weight,
              title: "Weight",
              value:
                  "${spool.labelWeight - spool.weightUsed}/${spool.labelWeight}",
              spoolColor: context.appColor.primary,
              progress:
                  (spool.labelWeight - spool.weightUsed) / spool.labelWeight,
            ),
            InfoCard(
              icon: Icons.qr_code,
              title: "Assigned QR-Code",
              value: spool.qrcode ?? "None",
              more: QRCodeMore(spool: spool),
            ),
            if (spool.assignment == null && widget.editable)
              Button(
                onPressed: () async {
                  Future<void> archive() async {
                    AvailableFilaments availableFilaments = context
                        .read<AvailableFilaments>();
                    await availableFilaments.archive(spool.id.toString());
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }

                  if (spool.labelWeight - spool.weightUsed <= 50) {
                    archive();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Archive?"),
                          content: const Text(
                            "Do you really want to archive this Spool? It has more than 50g available.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await archive();
                              },
                              child: const Text("Archive"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                expanded: true,
                backgroundColor: context.appColor.base3,
                borderColor: context.appColor.error,
                child: Text(
                  "Archive Spool",
                  style: TextStyle(color: context.appColor.error),
                ),
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
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                  backgroundColor: Colors.transparent,
                                ),
                              )
                            : SizedBox.square(
                                dimension: 250,
                                child: Center(
                                  child: AutoSizeText(
                                    "No assigned QR-Code",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 100,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: Button(
                  onPressed: () async {
                    assignQrCode();
                  },
                  expanded: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text("Assign QR-Code"),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Button(
                  onPressed: () {
                    unassignQrCode();
                  },
                  backgroundColor: Colors.transparent,
                  expanded: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove),
                      SizedBox(width: 8),
                      Text("Unassign QR-Code"),
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

  void unassignQrCode() async {
    final bool res = await deleteQrCodeReq(context, widget.spool);
    if (res) print("Deleted successfully");
    if (!mounted) return;
    Navigator.pop(context);
  }

  void assignQrCode() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Qrscan();
        },
      ),
    );
    if (res == null) return;
    if (!mounted) return;
    final AvailableFilaments availableFilaments = context
        .read<AvailableFilaments>();
    final List alreadyAssigned = await availableFilaments.getSpoolsByQrCode(
      res,
    );
    if (!mounted) return;
    if (alreadyAssigned.isNotEmpty) {
      showSnackbar(
        context,
        "The following spools are assigned to this qrcode: ${alreadyAssigned.map((s) => s.id)}",
        context.appColor.error,
      );
      return;
    }
    if (!mounted) return;
    final bool success = await addQrCodeReq(context, widget.spool, res);
    if (!mounted) return;
    showSnackbar(
      context,
      success
          ? "Successfully assigned QR-Code to this Spool!"
          : "Could NOT assign this QR-Code to the spool!",
      success == true ? context.appColor.success : context.appColor.error,
    );
    Navigator.pop(context);
  }
}

class ColorNameMore extends StatefulWidget {
  const ColorNameMore({super.key, this.value});
  final String? value;

  @override
  State<ColorNameMore> createState() => _ColorNameMoreState();
}

class _ColorNameMoreState extends State<ColorNameMore> {
  final TextEditingController _colorNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      _colorNameController.text = widget.value ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _colorNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Color Name")),
      body: Row(
        children: [
          Flexible(
            child: TextInput(
              controller: _colorNameController,
              hinttext: "Color Name",
            ),
          ),
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
