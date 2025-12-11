import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'package:drift/drift.dart' as drift;

class ProyectosProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Proyecto> _proyectos = [];
  bool _isLoading = false;

  ProyectosProvider(this._database) {
    loadProyectos();
  }

  List<Proyecto> get proyectos => _proyectos;
  bool get isLoading => _isLoading;

  Future<void> loadProyectos() async {
    _isLoading = true;
    notifyListeners();

    _proyectos = await _database.getAllProyectos();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProyecto({
    required String codigo,
    required String nombre,
    int? clienteId,
    int? estadoId,
  }) async {
    try {
      await _database.insertProyecto(
        ProyectosCompanion(
          codigo: drift.Value(codigo),
          nombre: drift.Value(nombre),
          clienteId: clienteId != null ? drift.Value(clienteId) : const drift.Value.absent(),
          estadoId: estadoId != null ? drift.Value(estadoId) : const drift.Value.absent(),
        ),
      );
      await loadProyectos();
      return true;
    } catch (e) {
      print('Error creating proyecto: $e');
      return false;
    }
  }

  Future<bool> updateProyecto({
    required int id,
    required String codigo,
    required String nombre,
    int? clienteId,
    int? estadoId,
  }) async {
    try {
      final proyecto = await _database.getProyecto(id);
      final updatedProyecto = proyecto.copyWith(
        codigo: codigo,
        nombre: nombre,
        clienteId: drift.Value(clienteId),
        estadoId: drift.Value(estadoId),
        fechaModificacion: DateTime.now(),
      );
      await _database.updateProyecto(updatedProyecto);
      await loadProyectos();
      return true;
    } catch (e) {
      print('Error updating proyecto: $e');
      return false;
    }
  }

  Future<bool> deleteProyecto(int id) async {
    try {
      await _database.deleteProyecto(id);
      await loadProyectos();
      return true;
    } catch (e) {
      print('Error deleting proyecto: $e');
      return false;
    }
  }

  Proyecto? getProyectoById(int id) {
    try {
      return _proyectos.firstWhere((proyecto) => proyecto.id == id);
    } catch (e) {
      return null;
    }
  }
}
