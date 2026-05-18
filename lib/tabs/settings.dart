import 'dart:async';

import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/services/app_state.dart';
import 'package:bamscan/services/ble.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/services/scale_service.dart';
import 'package:bamscan/services/snackbar_service.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/utils/parse_note.dart';
import 'package:bamscan/widgets/ble_not_enabled.dart';
import 'package:bamscan/widgets/infocard.dart';
import 'package:bamscan/widgets/textinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late TextEditingController _bambuddyUrlController;
  late TextEditingController _xapiTokenController;

  String weight = "";

  @override
  void initState() {
    super.initState();
    _bambuddyUrlController = TextEditingController();
    _xapiTokenController = TextEditingController();

    ScaleService().stream.listen((scale) {
      if (!mounted) return;
      setState(() {
        weight = scale.weight.toString();
      });
    });

    loadData();
  }

  void loadData() async {
    StorageService storageService = context.read<StorageService>();

    _bambuddyUrlController.text = storageService.getString(StorageService.kBambuddyUrl);
    _xapiTokenController.text = await storageService.getSecureString(StorageService.kXApiToken);
    setState(() {});
  }

  @override
  void dispose() {
    _bambuddyUrlController.dispose();
    _xapiTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = context.watch<StorageService>();

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InfoCard(
                title: "General",
                icon: Icons.tune,
                more: Setting(
                  title: "General",
                  widgets: [
                    InfoCard(
                      title: "Show QR/NFC icons",
                      subtitle: "In the filament list.",
                      icon: Icons.qr_code_scanner,
                      value: Consumer<StorageService>(
                        builder: (context, storageService, _) => Switch(
                          value: storageService.getBool(StorageService.kShowIcons),
                          onChanged: (value) {
                            storageService.setBool(StorageService.kShowIcons, value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InfoCard(
                title: "Connection",
                value: "",
                icon: MdiIcons.connection,
                more: PopScope(
                  onPopInvokedWithResult: (didPop, result) {
                    storageService.setString(StorageService.kBambuddyUrl, _bambuddyUrlController.text);
                    storageService.setSecureString(StorageService.kXApiToken, _xapiTokenController.text);
                  },
                  child: Setting(
                    title: "Connection",
                    widgets: [
                      TextInput(
                        controller: _bambuddyUrlController,
                        onTapOutside: () => storageService.setString(StorageService.kBambuddyUrl, _bambuddyUrlController.text),
                        labeltext: "Bambuddy URL:PORT",
                        hinttext: "e.g. http://127.0.0.1:8000",
                      ),
                      TextInput(
                        controller: _xapiTokenController,
                        onTapOutside: () => storageService.setSecureString(StorageService.kXApiToken, _xapiTokenController.text),
                        obscure: true,
                        labeltext: "Bambuddy API Key",
                        hinttext: "Bambuddy Website -> Settings -> API Keys",
                      ),
                    ],
                  ),
                ),
              ),
              InfoCard(
                title: "Appearance",
                value: "",
                icon: Icons.brush,
                more: Setting(
                  title: "Appearance",
                  widgets: [
                    InfoCard(
                      title: "Theme",
                      icon: Icons.contrast,
                      value: Consumer<StorageService>(
                        builder: (context, storageService, _) {
                          return DropdownMenu<String>(
                            initialSelection: storageService.getString(StorageService.kDarkMode),
                            dropdownMenuEntries: ["System", "Light", "Dark"].map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
                            onSelected: (value) async {
                              if (value != null) {
                                await storageService.setString(StorageService.kDarkMode, value);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              InfoCard(
                title: "Reset",
                value: "",
                icon: Icons.restore,
                more: Setting(
                  title: "Reset",
                  widgets: [
                    InfoCard(
                      title: "Reset app data",
                      value: "",
                      icon: Icons.restore,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Are you sure?"),
                              content: Text("This will delete the Bambuddy URL and Bambuddy API Key from the app."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final storage = StorageService();
                                    storage.deleteAllData();
                                    Navigator.pop(context);
                                  },
                                  child: Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    InfoCard(title: "Reset QR-Codes", value: "", icon: MdiIcons.qrcodeRemove, onTap: () => deleteAllMappings(context, "qr")),
                    InfoCard(title: "Reset NFC-Tags", value: "", icon: MdiIcons.nfcVariantOff, onTap: () => deleteAllMappings(context, "nfc")),
                  ],
                ),
              ),
              InfoCard(
                title: "Bluetooth",
                icon: Icons.bluetooth,
                more: Setting(
                  title: "Bluetooth",
                  widgets: [
                    InfoCard(title: "Scale", icon: Icons.scale, value: StorageService().getString(StorageService.kBleRemoteId) == "" ? "None" : "Paired", more: BluetoothScan()),
                  ],
                ),
              ),
              if (false)
                InfoCard(
                  title: "Beta Features",
                  value: "",
                  icon: Icons.rocket,
                  more: Setting(
                    title: "Beta Features",
                    widgets: [
                      InfoCard(
                        title: "External Spool",
                        value: Consumer<StorageService>(
                          builder: (context, storageService, _) => Switch(
                            value: storageService.getBool(StorageService.kExternalSpool),
                            onChanged: (value) {
                              storageService.setBool(StorageService.kExternalSpool, value);
                            },
                          ),
                        ),
                        icon: MdiIcons.disc,
                      ),
                    ],
                  ),
                ),
              Text(AppStateService().version, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

void deleteAllMappings(BuildContext context, String kind) {
  showDialog(
    context: context,
    builder: (dialogcontext) {
      int tasksDone = 0;
      int taskcount = 1;
      bool started = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Are you sure?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(
                  "This will delete all ${kind == "nfc"
                      ? "NFC-Tag"
                      : kind == "qr"
                      ? "QR-Code"
                      : null} mappings in Bambuddy.",
                ),
                if (started) LinearProgressIndicator(value: tasksDone / taskcount),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogcontext);
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  final AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
                  await availableFilaments.getAllSpools();
                  setState(() {
                    started = true;
                    taskcount = availableFilaments.spools.length;
                  });
                  for (Spool spool in availableFilaments.spools) {
                    if (!context.mounted) {
                      return;
                    }
                    if (kind == "nfc") {
                      await deleteNfcReq(context, spool);
                      tasksDone++;
                    }
                    if (!context.mounted) {
                      return;
                    }
                    if (kind == "qr") {
                      await deleteQrCodeReq(context, spool);
                      tasksDone++;
                    }
                    setState(() {});
                  }
                  if (!context.mounted) {
                    return;
                  }
                  SnackbarService.success("Successfully resetted ${kind.toUpperCase()} mappings.");
                  Navigator.pop(dialogcontext);
                },
                child: Text("Yes"),
              ),
            ],
          );
        },
      );
    },
  );
}

class Setting extends StatefulWidget {
  const Setting({super.key, required this.title, required this.widgets});
  final String title;
  final Object widgets;

  @override
  State<Setting> createState() => SettingState();
}

class SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: widget.widgets is List<Widget>
            ? Column(spacing: 10, crossAxisAlignment: CrossAxisAlignment.start, children: widget.widgets as List<Widget>)
            : widget.widgets is Widget
            ? widget.widgets as Widget
            : null,
      ),
    );
  }
}

class BluetoothScan extends StatefulWidget {
  const BluetoothScan({super.key});

  @override
  State<BluetoothScan> createState() => _BluetoothScanState();
}

class _BluetoothScanState extends State<BluetoothScan> {
  List<ScanResult> scanRes = [];
  StreamSubscription? sub;

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connect device")),
      body: Consumer<DeviceCapabilities>(
        builder: (context, deviceCapabilities, child) {
          if (!deviceCapabilities.isBluetoothAvailable) {
            return BleNotEnabled();
          } else {
            if (!FlutterBluePlus.isScanningNow && DeviceCapabilities().isBluetoothAvailable) {
              sub = Ble().fetchDevices().listen((res) {
                if (!mounted) return;

                setState(() {
                  scanRes.addOrUpdate(res);
                });
              });
            }

            return ListView(
              children: [
                for (ScanResult res in scanRes) ...[
                  if (res.device.advName != "") ...[
                    InfoCard(
                      title: res.device.advName,
                      icon: Icons.bluetooth,
                      onTap: () async {
                        await Ble().connect(device: res.device);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      value: res.rssi.toString(),
                    ),
                  ],
                ],
                if (scanRes.isEmpty) Center(child: Text("No scales found!")),
              ],
            );
          }
        },
      ),
    );
  }
}
