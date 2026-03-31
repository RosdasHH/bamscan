import 'package:bambuscanner/services/storage.dart';
import 'package:flutter/material.dart';

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
    _bambuddyUrlController.text = StorageService().bambuddyUrl;
    _xapiTokenController.text = StorageService().xapitoken;
  }

  @override
  void dispose() {
    _bambuddyUrlController.dispose();
    _xapiTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _bambuddyUrlController),
            TextField(controller: _xapiTokenController, obscureText: true),
            ElevatedButton(
              onPressed: () {
                saveSettings();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void saveSettings() {
    StorageService.setBambuddyUrl(_bambuddyUrlController.text);
    StorageService.saveToken(_xapiTokenController.text);
  }
}
