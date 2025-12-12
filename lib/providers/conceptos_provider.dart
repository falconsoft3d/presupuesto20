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

  /// Recalcula totales de un presupuesto de forma recursiva
  Future<void> recalcularTotales(int presupuestoId) async {
    try {
      // Obtener todos los conceptos del presupuesto ordenados por nivel (más profundo primero)
      final conceptos = await (database.select(database.conceptos)
            ..where((c) => c.presupuestoId.equals(presupuestoId))
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.id,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

      // Set para rastrear qué conceptos ya fueron actualizados
      final Set<int> procesados = {};

      // Procesar cada concepto
      for (final concepto in conceptos) {
        if (procesados.contains(concepto.id)) continue;
        await _calcularConcepto(concepto, procesados);
      }

      // Recargar conceptos después del cálculo
      await loadConceptos();
    } catch (e) {
      debugPrint('Error recalculando totales: $e');
      rethrow;
    }
  }

  /// Calcula el total de un concepto y propaga hacia arriba
  Future<void> _calcularConcepto(
    Concepto concepto,
    Set<int> procesados,
  ) async {
    // Si ya fue procesado, saltar
    if (procesados.contains(concepto.id)) return;

    // Primero calcular todos los hijos
    final hijos = await (database.select(database.conceptos)
          ..where((c) => c.padreId.equals(concepto.id)))
        .get();

    // Calcular recursivamente los hijos primero
    for (final hijo in hijos) {
      await _calcularConcepto(hijo, procesados);
    }

    // Ahora calcular este concepto
    double nuevoCoste = 0.0;
    double nuevoImporte = 0.0;

    if (hijos.isEmpty) {
      // Concepto hoja (recurso): importe = cantidad × coste
      nuevoImporte = concepto.cantidad * concepto.coste;
      nuevoCoste = concepto.coste;
    } else {
      // Concepto padre (partida/capítulo): sumar importes de hijos
      for (final hijo in hijos) {
        nuevoImporte += hijo.importe;
      }
      
      // Para partidas y capítulos, el coste es igual al importe
      nuevoCoste = nuevoImporte;
    }

    // Actualizar si cambió
    if (nuevoCoste != concepto.coste || nuevoImporte != concepto.importe) {
      await (database.update(database.conceptos)
            ..where((c) => c.id.equals(concepto.id)))
          .write(
        ConceptosCompanion(
          coste: Value(nuevoCoste),
          importe: Value(nuevoImporte),
        ),
      );
    }

    // Marcar como procesado
    procesados.add(concepto.id);
  }
}
