import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'package:drift/drift.dart';

class PresupuestosProvider with ChangeNotifier {
  final AppDatabase database;
  List<Presupuesto> _presupuestos = [];
  bool _isLoading = false;

  PresupuestosProvider(this.database) {
    loadPresupuestos();
  }

  List<Presupuesto> get presupuestos => _presupuestos;
  bool get isLoading => _isLoading;

  Presupuesto? getPresupuestoById(int id) {
    try {
      return _presupuestos.firstWhere((presupuesto) => presupuesto.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadPresupuestos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _presupuestos = await database.getAllPresupuestos();
    } catch (e) {
      debugPrint('Error loading presupuestos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPresupuesto({
    required String codigo,
    required String nombre,
    int? companiaId,
    int? monedaId,
    int? estadoId,
    String tipoCalculo = 'Estandar',
  }) async {
    try {
      await database.insertPresupuesto(
        PresupuestosCompanion(
          codigo: Value(codigo),
          nombre: Value(nombre),
          companiaId: companiaId != null ? Value(companiaId) : const Value.absent(),
          monedaId: monedaId != null ? Value(monedaId) : const Value.absent(),
          estadoId: estadoId != null ? Value(estadoId) : const Value.absent(),
          tipoCalculo: Value(tipoCalculo),
        ),
      );
      await loadPresupuestos();
    } catch (e) {
      debugPrint('Error creating presupuesto: $e');
      rethrow;
    }
  }

  Future<void> updatePresupuesto({
    required int id,
    required String codigo,
    required String nombre,
    int? companiaId,
    int? monedaId,
    int? estadoId,
    String? tipoCalculo,
  }) async {
    try {
      final presupuesto = await database.getPresupuesto(id);
      await database.updatePresupuesto(
        presupuesto.copyWith(
          codigo: codigo,
          nombre: nombre,
          companiaId: Value.absentIfNull(companiaId),
          monedaId: Value.absentIfNull(monedaId),
          estadoId: Value.absentIfNull(estadoId),
          tipoCalculo: tipoCalculo,
          fechaModificacion: DateTime.now(),
        ),
      );
      await loadPresupuestos();
    } catch (e) {
      debugPrint('Error updating presupuesto: $e');
      rethrow;
    }
  }

  Future<void> deletePresupuesto(int id) async {
    try {
      await database.deletePresupuesto(id);
      await loadPresupuestos();
    } catch (e) {
      debugPrint('Error deleting presupuesto: $e');
      rethrow;
    }
  }
}
