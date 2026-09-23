import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências do usuário (tema e notificações), persistidas localmente.
class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'settings_theme_mode';
  static const String _pushKey = 'settings_notifications_push';
  static const String _offersKey = 'settings_notifications_offers';
  static const String _ordersKey = 'settings_notifications_orders';
  static const String _soundKey = 'settings_notifications_sound';

  ThemeMode _themeMode = ThemeMode.light;
  bool _pushEnabled = true;
  bool _offersEnabled = true;
  bool _ordersEnabled = true;
  bool _soundEnabled = true;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get pushEnabled => _pushEnabled;
  bool get offersEnabled => _offersEnabled;
  bool get ordersEnabled => _ordersEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get isLoaded => _isLoaded;

  SettingsProvider() {
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = _themeModeFromString(prefs.getString(_themeModeKey));
      _pushEnabled = prefs.getBool(_pushKey) ?? true;
      _offersEnabled = prefs.getBool(_offersKey) ?? true;
      _ordersEnabled = prefs.getBool(_ordersKey) ?? true;
      _soundEnabled = prefs.getBool(_soundKey) ?? true;
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _saveString(_themeModeKey, _themeModeToString(mode));
  }

  Future<void> toggleDarkMode(bool enabled) =>
      setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    // As notificações específicas dependem do interruptor geral.
    if (!value) {
      _offersEnabled = false;
      _ordersEnabled = false;
    }
    notifyListeners();
    await _saveBool(_pushKey, value);
    if (!value) {
      await _saveBool(_offersKey, false);
      await _saveBool(_ordersKey, false);
    }
  }

  Future<void> setOffersEnabled(bool value) async {
    _offersEnabled = value;
    notifyListeners();
    await _saveBool(_offersKey, value);
  }

  Future<void> setOrdersEnabled(bool value) async {
    _ordersEnabled = value;
    notifyListeners();
    await _saveBool(_ordersKey, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    await _saveBool(_soundKey, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Erro ao salvar preferência $key: $e');
    }
  }

  Future<void> _saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('Erro ao salvar preferência $key: $e');
    }
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}
