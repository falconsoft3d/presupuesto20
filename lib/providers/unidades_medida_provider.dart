import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class UnidadesMedidaProvider with ChangeNotifier {
  final AppDatabase _database;
  List<UnidadMedida> _unidades = [];
  bool _isLoading = false;

  UnidadesMedidaProvider(this._database) {
    loadUnidades();
  }

  List<UnidadMedida> get unidades => _unidades;
  bool get isLoading => _isLoading;

  Future<void> loadUnidades() async {
    _isLoading = true;
    notifyListeners();

    try {
      _unidades = await _database.getAllUnidadesMedida();
    } catch (e) {
      debugPrint('Error loading unidades medida: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUnidad({required String nombre}) async {
    try {
      final unidad = UnidadesMedidaCompanion.insert(
        nombre: nombre,
      );

      await _database.insertUnidadMedida(unidad);
      await loadUnidades();
      return true;
    } catch (e) {
      debugPrint('Error creating unidad medida: $e');
      return false;
    }
  }

  Future<bool> updateUnidad({
    required int id,
    required String nombre,
  }) async {
    try {
      final unidadActual = getUnidadById(id);
      if (unidadActual == null) return false;

      final unidad = UnidadMedida(
        id: id,
        nombre: nombre,
        fechaCreacion: unidadActual.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );

      await _database.updateUnidadMedida(unidad);
      await loadUnidades();
      return true;
    } catch (e) {
      debugPrint('Error updating unidad medida: $e');
      return false;
    }
  }

  Future<bool> deleteUnidad(int id) async {
    try {
      await _database.deleteUnidadMedida(id);
      await loadUnidades();
      return true;
    } catch (e) {
      debugPrint('Error deleting unidad medida: $e');
      return false;
    }
  }

  UnidadMedida? getUnidadById(int id) {
    try {
      return _unidades.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
