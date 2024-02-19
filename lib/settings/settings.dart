import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository._();

  static const String _kSkipIntroduction = "skipIntroduction";

  static Future<bool> getSkipIntroduction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSkipIntroduction) ?? false;
  }

  static Future<bool> setSkipIntroduction(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kSkipIntroduction, value);
  }
}