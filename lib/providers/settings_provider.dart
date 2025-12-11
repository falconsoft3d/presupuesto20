import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  Color _themeColor = const Color(0xFF875A7B); // Odoo purple default
  String? _homeBackgroundPath;
  String? _lockBackgroundPath;
  int? _companiaActualId;
  bool _registroHabilitado = true;
  
  Color get themeColor => _themeColor;
  String? get homeBackgroundPath => _homeBackgroundPath;
  String? get lockBackgroundPath => _lockBackgroundPath;
  int? get companiaActualId => _companiaActualId;
  bool get registroHabilitado => _registroHabilitado;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt('themeColor');
      if (colorValue != null) {
        _themeColor = Color(colorValue);
      }
      
      _homeBackgroundPath = prefs.getString('homeBackground');
      _lockBackgroundPath = prefs.getString('lockBackground');
      _companiaActualId = prefs.getInt('companiaActualId');
      _registroHabilitado = prefs.getBool('registroHabilitado') ?? true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeColor', color.value);
    } catch (e) {
      debugPrint('Error saving theme color: $e');
    }
  }

  Future<void> setHomeBackground(String? path) async {
    _homeBackgroundPath = path;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path != null) {
        await prefs.setString('homeBackground', path);
      } else {
        await prefs.remove('homeBackground');
      }
    } catch (e) {
      debugPrint('Error saving home background: $e');
    }
  }

  Future<void> setLockBackground(String? path) async {
    _lockBackgroundPath = path;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path != null) {
        await prefs.setString('lockBackground', path);
      } else {
        await prefs.remove('lockBackground');
      }
    } catch (e) {
      debugPrint('Error saving lock background: $e');
    }
  }

  Future<void> setCompaniaActual(int? companiaId) async {
    _companiaActualId = companiaId;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (companiaId != null) {
        await prefs.setInt('companiaActualId', companiaId);
      } else {
        await prefs.remove('companiaActualId');
      }
    } catch (e) {
      debugPrint('Error saving compania actual: $e');
    }
  }

  Future<void> setRegistroHabilitado(bool habilitado) async {
    _registroHabilitado = habilitado;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registroHabilitado', habilitado);
    } catch (e) {
      debugPrint('Error saving registro habilitado: $e');
    }
  }
}
