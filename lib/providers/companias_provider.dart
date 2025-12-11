import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class CompaniasProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Compania> _companias = [];
  bool _isLoading = false;

  CompaniasProvider(this._database) {
    loadCompanias();
  }

  List<Compania> get companias => _companias;
  bool get isLoading => _isLoading;

  Future<void> loadCompanias() async {
    _isLoading = true;
    notifyListeners();

    try {
      _companias = await _database.getAllCompanias();
    } catch (e) {
      debugPrint('Error loading companias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCompania({
    required String nombre,
    String? razonSocial,
    String? ruc,
    String? direccion,
    String? telefono,
    String? email,
    String? logo,
    bool activa = true,
  }) async {
    try {
      final compania = CompaniasCompanion.insert(
        nombre: nombre,
        razonSocial: Value(razonSocial),
        ruc: Value(ruc),
        direccion: Value(direccion),
        telefono: Value(telefono),
        email: Value(email),
        logo: Value(logo),
        activa: Value(activa),
      );

      await _database.insertCompania(compania);
      await loadCompanias();
      return true;
    } catch (e) {
      debugPrint('Error creating compania: $e');
      return false;
    }
  }

  Future<bool> updateCompania({
    required int id,
    required String nombre,
    String? razonSocial,
    String? ruc,
    String? direccion,
    String? telefono,
    String? email,
    String? logo,
    required bool activa,
  }) async {
    try {
      // Obtener la compañía actual
      final companiaActual = getCompaniaById(id);
      if (companiaActual == null) return false;

      final compania = Compania(
        id: id,
        nombre: nombre,
        razonSocial: razonSocial,
        ruc: ruc,
        direccion: direccion,
        telefono: telefono,
        email: email,
        logo: logo,
        activa: activa,
        fechaCreacion: companiaActual.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );

      await _database.updateCompania(CompaniasCompanion(
        id: Value(id),
        nombre: Value(nombre),
        razonSocial: Value(razonSocial),
        ruc: Value(ruc),
        direccion: Value(direccion),
        telefono: Value(telefono),
        email: Value(email),
        logo: Value(logo),
        activa: Value(activa),
        fechaModificacion: Value(DateTime.now()),
      ));
      await loadCompanias();
      return true;
    } catch (e) {
      debugPrint('Error updating compania: $e');
      return false;
    }
  }

  Future<bool> deleteCompania(int id) async {
    try {
      await _database.deleteCompania(id);
      await loadCompanias();
      return true;
    } catch (e) {
      debugPrint('Error deleting compania: $e');
      return false;
    }
  }

  Compania? getCompaniaById(int id) {
    try {
      return _companias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Compania> getCompaniasActivas() {
    return _companias.where((c) => c.activa).toList();
  }
}
