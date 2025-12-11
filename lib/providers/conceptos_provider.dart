import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'package:drift/drift.dart';

class ConceptosProvider with ChangeNotifier {
  final AppDatabase database;
  List<Concepto> _conceptos = [];
  bool _isLoading = false;

  ConceptosProvider(this.database) {
    loadConceptos();
  }

  List<Concepto> get conceptos => _conceptos;
  bool get isLoading => _isLoading;

  Future<void> loadConceptos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conceptos = await database.getAllConceptos();
    } catch (e) {
      debugPrint('Error loading conceptos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Concepto? getConceptoById(int id) {
    try {
      return _conceptos.firstWhere((concepto) => concepto.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createConcepto({
    required String codigo,
    required String nombre,
    int? productoId,
    double cantidad = 0.0,
    double coste = 0.0,
    double importe = 0.0,
    int? padreId,
    int? presupuestoId,
    required String tipoRecurso,
  }) async {
    try {
      await database.insertConcepto(
        ConceptosCompanion(
          codigo: Value(codigo),
          nombre: Value(nombre),
          productoId: productoId != null ? Value(productoId) : const Value.absent(),
          cantidad: Value(cantidad),
          coste: Value(coste),
          importe: Value(importe),
          padreId: padreId != null ? Value(padreId) : const Value.absent(),
          presupuestoId: presupuestoId != null ? Value(presupuestoId) : const Value.absent(),
          tipoRecurso: Value(tipoRecurso),
        ),
      );
      await loadConceptos();
    } catch (e) {
      debugPrint('Error creating concepto: $e');
      rethrow;
    }
  }

  Future<void> updateConcepto({
    required int id,
    required String codigo,
    required String nombre,
    int? productoId,
    double? cantidad,
    double? coste,
    double? importe,
    int? padreId,
    int? presupuestoId,
    String? tipoRecurso,
  }) async {
    try {
      final concepto = await database.getConcepto(id);
      await database.updateConcepto(
        concepto.copyWith(
          codigo: codigo,
          nombre: nombre,
          productoId: Value.absentIfNull(productoId),
          cantidad: cantidad ?? concepto.cantidad,
          coste: coste ?? concepto.coste,
          importe: importe ?? concepto.importe,
          padreId: Value.absentIfNull(padreId),
          presupuestoId: Value.absentIfNull(presupuestoId),
          tipoRecurso: tipoRecurso ?? concepto.tipoRecurso,
          fechaModificacion: DateTime.now(),
        ),
      );
      await loadConceptos();
    } catch (e) {
      debugPrint('Error updating concepto: $e');
      rethrow;
    }
  }

  Future<void> deleteConcepto(int id) async {
    try {
      await database.deleteConcepto(id);
      await loadConceptos();
    } catch (e) {
      debugPrint('Error deleting concepto: $e');
      rethrow;
    }
  }
}
