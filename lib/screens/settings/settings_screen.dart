import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:ripple/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {


  const SettingsScreen({
    super.key,

  });

  // Helper to convert ThemeMode to readable string
  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  // Helper to parse dropdown value back to ThemeMode
  ThemeMode _getThemeModeFromValue(String? value) {
    switch (value) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System Default':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final settingProvider = context.watch<SettingsProvider>();
    final currentLabel =  _getThemeLabel(settingProvider.currentThemeMode);


    //_getThemeLabel(currentThemeMode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: currentLabel,
              underline: const SizedBox(), // Removes default underline
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: const TextStyle(color: Colors.blue),
              onChanged: (String? newValue) {
                if (newValue != null) {
                 // final newMode = _getThemeModeFromValue(newValue);
                  // ─── Empty function placeholder ──────────────────────
                  context.read<SettingsProvider>().storeCurrentTheme(newValue);

                }
              },
              items: const [
                DropdownMenuItem<String>(
                  value: 'Light',
                  child: Text('Light'),
                ),
                DropdownMenuItem<String>(
                  value: 'Dark',
                  child: Text('Dark'),
                ),
                DropdownMenuItem<String>(
                  value: 'System Default',
                  child: Text('System Default'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}