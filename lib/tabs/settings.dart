import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/utils/parse_note.dart';
import 'package:bambuscanner/widgets/infocard.dart';
import 'package:bambuscanner/widgets/textinput.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _bambuddyUrlController = TextEditingController();
    _xapiTokenController = TextEditingController();

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
    final StorageService storageService = StorageService();

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              InfoCard(
                title: "Connection",
                value: "",
                icon: MdiIcons.connection,
                more: Setting(
                  title: "Connection",
                  widgets: [
                    TextInput(
                      controller: _bambuddyUrlController,
                      onTapOutside: () => storageService.setBambuddyUrl(
                        _bambuddyUrlController.text,
                      ),
                      labeltext: "Bambuddy URL:PORT",
                      hinttext: "e.g. http://127.0.0.1:8000",
                    ),
                    TextInput(
                      controller: _xapiTokenController,
                      onTapOutside: () =>
                          storageService.saveToken(_xapiTokenController.text),
                      obscure: true,
                      labeltext: "Bambuddy API Key",
                      hinttext: "Bambuddy Website -> Settings -> API Keys",
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
                              content: Text(
                                "This will delete the Bambuddy URL and Bambuddy API Key from the app.",
                              ),
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
                              content: Text(
                                "This will delete all QR-Code mappings.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final AvailableFilaments
                                    availableFilaments = context
                                        .read<AvailableFilaments>();
                                    await availableFilaments.getAllSpools();
                                    for (Spool spool
                                        in availableFilaments.spools) {
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
                  ],
                ),
              ),
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
  final List<Widget> widgets;

  @override
  State<Setting> createState() => SettingState();
}

class SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.widgets,
        ),
      ),
    );
  }
}
