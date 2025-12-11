import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class MonedasProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Moneda> _monedas = [];
  bool _isLoading = false;

  MonedasProvider(this._database) {
    loadMonedas();
  }

  List<Moneda> get monedas => _monedas;
  bool get isLoading => _isLoading;

  Future<void> loadMonedas() async {
    _isLoading = true;
    notifyListeners();

    try {
      _monedas = await _database.getAllMonedas();
    } catch (e) {
      debugPrint('Error loading monedas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMoneda({
    required String nombre,
    required String signo,
  }) async {
    try {
      final moneda = MonedasCompanion.insert(
        nombre: nombre,
        signo: signo,
      );

      await _database.insertMoneda(moneda);
      await loadMonedas();
      return true;
    } catch (e) {
      debugPrint('Error creating moneda: $e');
      return false;
    }
  }

  Future<bool> updateMoneda({
    required int id,
    required String nombre,
    required String signo,
  }) async {
    try {
      final monedaActual = getMonedaById(id);
      if (monedaActual == null) return false;

      final moneda = Moneda(
        id: id,
        nombre: nombre,
        signo: signo,
        fechaCreacion: monedaActual.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );

      await _database.updateMoneda(moneda);
      await loadMonedas();
      return true;
    } catch (e) {
      debugPrint('Error updating moneda: $e');
      return false;
    }
  }

  Future<bool> deleteMoneda(int id) async {
    try {
      await _database.deleteMoneda(id);
      await loadMonedas();
      return true;
    } catch (e) {
      debugPrint('Error deleting moneda: $e');
      return false;
    }
  }

  Moneda? getMonedaById(int id) {
    try {
      return _monedas.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}
