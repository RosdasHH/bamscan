import 'dart:async';

import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/services/ble.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/services/scale_service.dart';
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
    setState(() {
      _bambuddyUrlController.text = StorageService().bambuddyUrl;
      _xapiTokenController.text = StorageService().xapitoken;
    });
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
                          value: storageService.showicons,
                          onChanged: (value) {
                            storageService.setShowIcons(value);
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
                more: Setting(
                  title: "Connection",
                  widgets: [
                    TextInput(
                      controller: _bambuddyUrlController,
                      onTapOutside: () => storageService.setBambuddyUrl(_bambuddyUrlController.text),
                      labeltext: "Bambuddy URL:PORT",
                      hinttext: "e.g. http://127.0.0.1:8000",
                    ),
                    TextInput(
                      controller: _xapiTokenController,
                      onTapOutside: () => storageService.saveToken(_xapiTokenController.text),
                      obscure: true,
                      labeltext: "Bambuddy API Key",
                      hinttext: "Bambuddy Website -> Settings -> API Keys",
                    ),
                  ],
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
                            initialSelection: storageService.darkMode,
                            dropdownMenuEntries: ["System", "Light", "Dark"].map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
                            onSelected: (value) async {
                              if (value != null) {
                                await storageService.setDarkMode(value);
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
                    InfoCard(
                      title: "Reset QR-Codes",
                      value: "",
                      icon: MdiIcons.qrcodeRemove,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Are you sure?"),
                              content: Text("This will delete all QR-Code mappings Bambuddy."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
                                    await availableFilaments.getAllSpools();
                                    for (Spool spool in availableFilaments.spools) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      await deleteQrCodeReq(context, spool);
                                    }
                                    if (!context.mounted) {
                                      return;
                                    }
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
                    InfoCard(
                      title: "Reset NFC-Tags",
                      value: "",
                      icon: MdiIcons.nfcVariantOff,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Are you sure?"),
                              content: Text("This will delete all NFC-Tag mappings in Bambuddy."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
                                    await availableFilaments.getAllSpools();
                                    for (Spool spool in availableFilaments.spools) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      await deleteNfcReq(context, spool);
                                    }
                                    if (!context.mounted) {
                                      return;
                                    }
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
                  ],
                ),
              ),
              InfoCard(
                title: "Bluetooth",
                icon: Icons.bluetooth,
                more: Setting(
                  title: "Bluetooth",
                  widgets: [InfoCard(title: "Scale", icon: Icons.scale, value: storageService.bleRemoteId == "" ? "None" : "Paired", more: BluetoothScan())],
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
                            value: storageService.externalSpool,
                            onChanged: (value) {
                              storageService.setExternalSpool(value);
                            },
                          ),
                        ),
                        icon: MdiIcons.disc,
                      ),
                    ],
                  ),
                ),
              Text(storageService.version, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
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
              ],
            );
          }
        },
      ),
    );
  }
}
