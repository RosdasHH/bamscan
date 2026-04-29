import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  static final _secureStorage = FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  String _bambuddyUrl = "";
  String _xapitoken = "";
  bool _firstUse = true;
  final bool _externalSpool = false;
  String _version = "0.0.0";
  String _darkMode = "System";
  bool _showicons = true;
  String? _lastVersion;
  bool _firstLaunchAfterUpdate = false;

  String get bambuddyUrl => _bambuddyUrl;
  String get xapitoken => _xapitoken;
  bool get firstUse => _firstUse;
  bool get externalSpool => _externalSpool;
  String get version => _version;
  String get darkMode => _darkMode;
  bool get showicons => _showicons;
  bool get firstLaunchAfterUpdate => _firstLaunchAfterUpdate;

  Future<void> loadFromStorage() async {
    _bambuddyUrl = await getBambuddyUrl();
    _xapitoken = await getToken();
    _firstUse = await getFirseUse();
    //_externalSpool = await getExternalSpool();
    _version = await getVersion();
    _darkMode = await getDarkMode();
    _showicons = await getShowIcons();
    _lastVersion = await getLastVersion();

    if (_lastVersion != _version && firstUse == false) {
      _firstLaunchAfterUpdate = true;
      _lastVersion = _version;
    }

    notifyListeners();
  }

  Future<String> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return ("Version: ${info.version}+${info.buildNumber}");
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
    await loadFromStorage();
  }

  static Future<String> getToken() async {
    return await _secureStorage.read(key: 'token') ?? "";
  }

  //static Future<void> deleteToken() async {
  //  await _secureStorage.delete(key: 'token');
  //}

  Future<void> setBambuddyUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("bambuddyUrl", url);
    await loadFromStorage();
  }

  Future<void> setFirstUse(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("firstuse", value);
    await loadFromStorage();
  }

  Future<void> setExternalSpool(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("externalSpool", value);
    await loadFromStorage();
  }

  Future<void> setDarkMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("darkmode", value);
    await loadFromStorage();
  }

  Future<void> setShowIcons(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("showicons", value);
    await loadFromStorage();
  }

  static Future<String> getBambuddyUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("bambuddyUrl") ?? "";
  }

  static Future<bool> getFirseUse() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("firstuse") ?? true;
  }

  static Future<bool> getExternalSpool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("externalSpool") ?? false;
  }

  static Future<String> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("darkmode") ?? "System";
  }

  static Future<String?> getLastVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("lastVersion");
  }

  static Future<bool> getShowIcons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("showicons") ?? true;
  }

  Future<void> deleteAllData() async {
    final storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
    await storage.deleteAll();
    loadFromStorage();
    notifyListeners();
  }
}
