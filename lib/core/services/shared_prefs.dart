import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

class SharedPrefs {
 // final prefs = await SharedPreferences.getInstance();

  void saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppStrings.themeModePrefs, theme);
  }

  Future<String?> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppStrings.themeModePrefs);
  }
}