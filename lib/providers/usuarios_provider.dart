import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database.dart';

class UsuariosProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  UsuariosProvider(this._database) {
    loadUsuarios();
  }

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;

  Future<void> loadUsuarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuarios = await _database.getAllUsuarios();
    } catch (e) {
      debugPrint('Error loading usuarios: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUsuario({
    required String nombre,
    required String email,
    required String password,
    String perfil = 'administrador',
    String? foto,
  }) async {
    try {
      // Hash the password
      final bytes = utf8.encode(password);
      final hash = sha256.convert(bytes);
      final hashedPassword = hash.toString();

      final usuario = UsuariosCompanion.insert(
        nombre: nombre,
        email: email,
        password: hashedPassword,
        perfil: Value(perfil),
        foto: Value(foto),
      );

      await _database.insertUsuario(usuario);
      await loadUsuarios();
      return true;
    } catch (e) {
      debugPrint('Error creating usuario: $e');
      return false;
    }
  }

  Future<bool> updateUsuario({
    required int id,
    required String nombre,
    required String email,
    String? newPassword,
    String? perfil,
    String? foto,
  }) async {
    try {
      // Obtener el usuario actual
      final usuarioActual = getUsuarioById(id);
      if (usuarioActual == null) return false;

      // Determinar la contraseña a usar
      String passwordFinal = usuarioActual.password;
      if (newPassword != null && newPassword.isNotEmpty) {
        final bytes = utf8.encode(newPassword);
        final hash = sha256.convert(bytes);
        passwordFinal = hash.toString();
      }

      final usuario = Usuario(
        id: id,
        nombre: nombre,
        email: email,
        password: passwordFinal,
        perfil: perfil ?? usuarioActual.perfil,
        foto: foto ?? usuarioActual.foto,
        fechaCreacion: usuarioActual.fechaCreacion,
        ultimoAcceso: usuarioActual.ultimoAcceso,
      );

      await _database.updateUsuario(usuario);
      await loadUsuarios();
      return true;
    } catch (e) {
      debugPrint('Error updating usuario: $e');
      return false;
    }
  }

  Future<bool> deleteUsuario(int id) async {
    try {
      await _database.deleteUsuario(id);
      await loadUsuarios();
      return true;
    } catch (e) {
      debugPrint('Error deleting usuario: $e');
      return false;
    }
  }

  Usuario? getUsuarioById(int id) {
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
