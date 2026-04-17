import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  static final _secureStorage = FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  String _bambuddyUrl = "";
  String _xapitoken = "";
  bool _firstUse = true;
  bool _externalSpool = false;

  String get bambuddyUrl => _bambuddyUrl;
  String get xapitoken => _xapitoken;
  bool get firstUse => _firstUse;
  bool get externalSpool => _externalSpool;

  Future<void> loadFromStorage() async {
    _bambuddyUrl = await getBambuddyUrl();
    _xapitoken = await getToken();
    _firstUse = await getFirseUse();
    _externalSpool = await getExternalSpool();
    notifyListeners();
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

  Future<void> deleteAllData() async {
    final storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
    await storage.deleteAll();
    loadFromStorage();
    notifyListeners();
  }
}
