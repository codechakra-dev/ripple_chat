import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ripple/core/constants/app_strings.dart';
import 'package:ripple/core/services/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode currentThemeMode = ThemeMode.system;


  final SharedPrefs _sharedPrefs = SharedPrefs();


  SettingsProvider()  {
    ()async{
      currentThemeMode  = await getCurrentTheme() ?? ThemeMode.system;

    }();
  }
  Future<ThemeMode?> getCurrentTheme() async{
    String? theme =  await _sharedPrefs.getSavedTheme();
    setCurrentTheme(theme ?? "");
    return currentThemeMode;

  }

  void storeCurrentTheme(String theme) async {
    _sharedPrefs.saveTheme(theme);
    setCurrentTheme(theme);

  }

  void setCurrentTheme(String theme){
    switch(theme){
      case "Light":
        currentThemeMode = ThemeMode.light;
        break;
      case "Dark":
        currentThemeMode = ThemeMode.dark;
        break;
      default:
        currentThemeMode = ThemeMode.system;
    }
    notifyListeners();
  }

}
