import 'package:bamscan/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();

  factory AppStateService() => _instance;

  AppStateService._internal();

  final StorageService storage = StorageService();

  String version = "";
  bool firstLaunchAfterUpdate = false;

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = "${info.version}+${info.buildNumber}";

    final lastVersion = storage.getString(StorageService.kLastVersion);

    final firstUse = storage.getBool(StorageService.kFirstUse, defaultValue: true);

    version = currentVersion;

    if (lastVersion != currentVersion && !firstUse) {
      firstLaunchAfterUpdate = true;
    }

    await storage.setString(StorageService.kLastVersion, currentVersion);

    notifyListeners();
  }
}
