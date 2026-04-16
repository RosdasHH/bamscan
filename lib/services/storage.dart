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

  String get bambuddyUrl => _bambuddyUrl;
  String get xapitoken => _xapitoken;
  bool get firstUse => _firstUse;

  Future<void> loadFromStorage() async {
    _bambuddyUrl = await getBambuddyUrl();
    _xapitoken = await getToken();
    _firstUse = await getFirseUse();
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

  static Future<String> getBambuddyUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("bambuddyUrl") ?? "";
  }

  static Future<bool> getFirseUse() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("firstuse") ?? true;
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
