import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  late SharedPreferences _prefs;

  static const kBambuddyUrl = 'bambuddyUrl';
  static const kFirstUse = 'firstuse';
  static const kDarkMode = 'darkmode';
  static const kShowIcons = 'showicons';
  static const kLastVersion = 'lastVersion';
  static const kXApiToken = 'token';
  static const kCamToken = 'camToken';
  static const kExternalSpool = 'externalSpool';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    StorageService().setBool(StorageService.kExternalSpool, false);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
    notifyListeners();
  }

  String getString(String key, {String defaultValue = ""}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    notifyListeners();
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);

    notifyListeners();
  }

  Future<String> getSecureString(String key) async {
    return await _secureStorage.read(key: key) ?? "";
  }

  Future<void> deleteAllData() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
    notifyListeners();
  }
}
