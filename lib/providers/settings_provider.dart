import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  Color _themeColor = const Color(0xFF875A7B); // Odoo purple default
  Color _homeBackgroundColor = const Color(0xFFF0F0F0); // Color de fondo por defecto
  String? _homeBackgroundPath;
  String? _lockBackgroundPath;
  int? _companiaActualId;
  bool _registroHabilitado = true;
  
  // Secuencias
  String _secuenciaProyecto = 'PY';
  int _proximoNumeroProyecto = 1;
  String _secuenciaPresupuesto = 'PR';
  int _proximoNumeroPresupuesto = 1;
  int _contadorIntegrador = 0;
  
  // Integración RPC
  String _rpcUrl = '';
  String _rpcPuerto = '8069';
  String _rpcDatabase = '';
  String _rpcUsuario = '';
  String _rpcContrasena = '';
  
  // ChatGPT
  String _chatGptToken = '';
  
  // PIN de desbloqueo
  bool _usarPin = false;
  String _pinCode = '';
  String _ultimoEmailUsuario = '';
  
  Color get themeColor => _themeColor;
  Color get homeBackgroundColor => _homeBackgroundColor;
  String? get homeBackgroundPath => _homeBackgroundPath;
  String? get lockBackgroundPath => _lockBackgroundPath;
  int? get companiaActualId => _companiaActualId;
  bool get registroHabilitado => _registroHabilitado;
  
  String get secuenciaProyecto => _secuenciaProyecto;
  int get proximoNumeroProyecto => _proximoNumeroProyecto;
  String get secuenciaPresupuesto => _secuenciaPresupuesto;
  int get proximoNumeroPresupuesto => _proximoNumeroPresupuesto;
  int get contadorIntegrador => _contadorIntegrador;
  
  String get rpcUrl => _rpcUrl;
  String get rpcPuerto => _rpcPuerto;
  String get rpcDatabase => _rpcDatabase;
  String get rpcUsuario => _rpcUsuario;
  String get rpcContrasena => _rpcContrasena;
  String get chatGptToken => _chatGptToken;
  
  bool get usarPin => _usarPin;
  String get pinCode => _pinCode;
  String get ultimoEmailUsuario => _ultimoEmailUsuario;

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
      
      final homeBackgroundColorValue = prefs.getInt('homeBackgroundColor');
      if (homeBackgroundColorValue != null) {
        _homeBackgroundColor = Color(homeBackgroundColorValue);
      }
      
      _homeBackgroundPath = prefs.getString('homeBackground');
      _lockBackgroundPath = prefs.getString('lockBackground');
      _companiaActualId = prefs.getInt('companiaActualId');
      _registroHabilitado = prefs.getBool('registroHabilitado') ?? true;
      
      // Cargar secuencias
      _secuenciaProyecto = prefs.getString('secuenciaProyecto') ?? 'PY';
      _proximoNumeroProyecto = prefs.getInt('proximoNumeroProyecto') ?? 1;
      _secuenciaPresupuesto = prefs.getString('secuenciaPresupuesto') ?? 'PR';
      _proximoNumeroPresupuesto = prefs.getInt('proximoNumeroPresupuesto') ?? 1;
      _contadorIntegrador = prefs.getInt('contadorIntegrador') ?? 0;
      
      // Cargar integración RPC
      _rpcUrl = prefs.getString('rpcUrl') ?? '';
      _rpcPuerto = prefs.getString('rpcPuerto') ?? '8069';
      _rpcDatabase = prefs.getString('rpcDatabase') ?? '';
      _rpcUsuario = prefs.getString('rpcUsuario') ?? '';
      _rpcContrasena = prefs.getString('rpcContrasena') ?? '';
      
      // Cargar ChatGPT
      _chatGptToken = prefs.getString('chatGptToken') ?? '';
      
      // Cargar PIN
      _usarPin = prefs.getBool('usarPin') ?? false;
      _pinCode = prefs.getString('pinCode') ?? '';
      _ultimoEmailUsuario = prefs.getString('ultimoEmailUsuario') ?? '';
      
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

  Future<void> setHomeBackgroundColor(Color color) async {
    _homeBackgroundColor = color;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('homeBackgroundColor', color.value);
    } catch (e) {
      debugPrint('Error saving home background color: $e');
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

  Future<void> setSecuenciaProyecto(String secuencia) async {
    _secuenciaProyecto = secuencia;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('secuenciaProyecto', secuencia);
    } catch (e) {
      debugPrint('Error saving secuencia proyecto: $e');
    }
  }

  Future<void> setProximoNumeroProyecto(int numero) async {
    _proximoNumeroProyecto = numero;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('proximoNumeroProyecto', numero);
    } catch (e) {
      debugPrint('Error saving proximo numero proyecto: $e');
    }
  }

  Future<void> setSecuenciaPresupuesto(String secuencia) async {
    _secuenciaPresupuesto = secuencia;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('secuenciaPresupuesto', secuencia);
    } catch (e) {
      debugPrint('Error saving secuencia presupuesto: $e');
    }
  }

  Future<void> setProximoNumeroPresupuesto(int numero) async {
    _proximoNumeroPresupuesto = numero;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('proximoNumeroPresupuesto', numero);
    } catch (e) {
      debugPrint('Error saving proximo numero presupuesto: $e');
    }
  }

  String generarCodigoProyecto() {
    final codigo = '$_secuenciaProyecto${_proximoNumeroProyecto.toString().padLeft(5, '0')}';
    setProximoNumeroProyecto(_proximoNumeroProyecto + 1);
    return codigo;
  }

  String generarCodigoPresupuesto() {
    final codigo = '$_secuenciaPresupuesto${_proximoNumeroPresupuesto.toString().padLeft(5, '0')}';
    setProximoNumeroPresupuesto(_proximoNumeroPresupuesto + 1);
    return codigo;
  }

  Future<void> incrementarContadorIntegrador() async {
    _contadorIntegrador++;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('contadorIntegrador', _contadorIntegrador);
    } catch (e) {
      debugPrint('Error saving contador integrador: $e');
    }
  }

  Future<void> setRpcUrl(String url) async {
    _rpcUrl = url;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpcUrl', url);
    } catch (e) {
      debugPrint('Error saving rpc url: $e');
    }
  }

  Future<void> setRpcPuerto(String puerto) async {
    _rpcPuerto = puerto;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpcPuerto', puerto);
    } catch (e) {
      debugPrint('Error saving rpc puerto: $e');
    }
  }

  Future<void> setRpcDatabase(String database) async {
    _rpcDatabase = database;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpcDatabase', database);
    } catch (e) {
      debugPrint('Error saving rpc database: $e');
    }
  }

  Future<void> setRpcUsuario(String usuario) async {
    _rpcUsuario = usuario;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpcUsuario', usuario);
    } catch (e) {
      debugPrint('Error saving rpc usuario: $e');
    }
  }

  Future<void> setRpcContrasena(String contrasena) async {
    _rpcContrasena = contrasena;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpcContrasena', contrasena);
    } catch (e) {
      debugPrint('Error saving rpc contrasena: $e');
    }
  }
  
  Future<void> setChatGptToken(String token) async {
    _chatGptToken = token;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chatGptToken', token);
    } catch (e) {
      debugPrint('Error saving chatGpt token: $e');
    }
  }
  
  Future<void> setUsarPin(bool usar) async {
    _usarPin = usar;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('usarPin', usar);
    } catch (e) {
      debugPrint('Error saving usar pin: $e');
    }
  }
  
  Future<void> setPinCode(String pin) async {
    _pinCode = pin;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pinCode', pin);
    } catch (e) {
      debugPrint('Error saving pin code: $e');
    }
  }
  
  bool verificarPin(String pin) {
    return _pinCode == pin;
  }
  
  Future<void> setUltimoEmailUsuario(String email) async {
    _ultimoEmailUsuario = email;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ultimoEmailUsuario', email);
    } catch (e) {
      debugPrint('Error saving ultimo email usuario: $e');
    }
  }
}
