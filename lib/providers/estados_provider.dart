import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'package:drift/drift.dart' as drift;

class EstadosProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Estado> _estados = [];
  bool _isLoading = false;

  EstadosProvider(this._database) {
    loadEstados();
  }

  List<Estado> get estados => _estados;
  bool get isLoading => _isLoading;

  Future<void> loadEstados() async {
    _isLoading = true;
    notifyListeners();

    _estados = await _database.getAllEstados();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEstado({
    required String nombre,
  }) async {
    try {
      await _database.insertEstado(
        EstadosCompanion(
          nombre: drift.Value(nombre),
        ),
      );
      await loadEstados();
      return true;
    } catch (e) {
      print('Error creating estado: $e');
      return false;
    }
  }

  Future<bool> updateEstado({
    required int id,
    required String nombre,
  }) async {
    try {
      final estado = await _database.getEstado(id);
      final updatedEstado = estado.copyWith(
        nombre: nombre,
        fechaModificacion: DateTime.now(),
      );
      await _database.updateEstado(updatedEstado);
      await loadEstados();
      return true;
    } catch (e) {
      print('Error updating estado: $e');
      return false;
    }
  }

  Future<bool> deleteEstado(int id) async {
    try {
      await _database.deleteEstado(id);
      await loadEstados();
      return true;
    } catch (e) {
      print('Error deleting estado: $e');
      return false;
    }
  }

  Estado? getEstadoById(int id) {
    try {
      return _estados.firstWhere((estado) => estado.id == id);
    } catch (e) {
      return null;
    }
  }
}
