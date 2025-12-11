import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database.dart';

class AuthProvider with ChangeNotifier {
  final AppDatabase _database;
  Usuario? _currentUser;
  bool _isAuthenticated = false;
  bool _isLocked = false;

  AuthProvider(this._database);

  Usuario? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLocked => _isLocked;
  bool get isAdministrador => _currentUser?.perfil == 'administrador';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> checkIfHasUsers() async {
    return await _database.hasUsuarios();
  }

  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      // Verificar si el email ya existe
      final existingUser = await _database.getUsuarioByEmail(email);
      if (existingUser != null) {
        return false;
      }

      // Crear usuario
      final hashedPassword = _hashPassword(password);
      final usuario = UsuariosCompanion(
        nombre: drift.Value(nombre),
        email: drift.Value(email),
        password: drift.Value(hashedPassword),
        perfil: const drift.Value('administrador'),
        fechaCreacion: drift.Value(DateTime.now()),
      );

      await _database.insertUsuario(usuario);
      
      // Iniciar sesión automáticamente después del registro
      return await login(email: email, password: password);
    } catch (e) {
      debugPrint('Error en registro: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final usuario = await _database.getUsuarioByEmail(email);
      
      if (usuario == null) {
        return false;
      }

      final hashedPassword = _hashPassword(password);
      
      if (usuario.password != hashedPassword) {
        return false;
      }

      // Actualizar último acceso
      final updatedUser = usuario.copyWith(
        ultimoAcceso: drift.Value(DateTime.now()),
      );
      await _database.updateUsuario(updatedUser);

      _currentUser = updatedUser;
      _isAuthenticated = true;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error en login: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _isLocked = false;
    notifyListeners();
  }

  void lock() {
    _isLocked = true;
    notifyListeners();
  }

  Future<bool> unlock(String password) async {
    if (_currentUser == null) {
      return false;
    }

    final hashedPassword = _hashPassword(password);
    
    if (_currentUser!.password != hashedPassword) {
      return false;
    }

    _isLocked = false;
    notifyListeners();
    return true;
  }

  Future<void> changePassword(int userId, String newHashedPassword) async {
    try {
      final usuario = _currentUser;
      if (usuario == null || usuario.id != userId) {
        throw Exception('Usuario no encontrado');
      }

      final updatedUser = usuario.copyWith(
        password: newHashedPassword,
      );
      
      await _database.updateUsuario(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cambiando contraseña: $e');
      rethrow;
    }
  }
}
