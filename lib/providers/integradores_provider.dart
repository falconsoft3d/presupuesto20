import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'package:drift/drift.dart' as drift;

class IntegradoresProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Integrador> _integradores = [];
  bool _isLoading = false;

  List<Integrador> get integradores => _integradores;
  bool get isLoading => _isLoading;

  IntegradoresProvider(this._database) {
    loadIntegradores();
  }

  Future<void> loadIntegradores() async {
    _isLoading = true;
    notifyListeners();

    _integradores = await _database.getAllIntegradores();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createIntegrador({
    required String secuencia,
    required String tipo,
    required String nombreArchivo,
    required String rutaArchivo,
  }) async {
    await _database.insertIntegrador(
      IntegradoresCompanion.insert(
        secuencia: secuencia,
        tipo: tipo,
        nombreArchivo: nombreArchivo,
        rutaArchivo: rutaArchivo,
      ),
    );
    await loadIntegradores();
  }

  Future<void> updateIntegrador({
    required int id,
    required String secuencia,
    required String tipo,
    required String nombreArchivo,
    required String rutaArchivo,
    String? estado,
    String? resultado,
    DateTime? fechaProcesamiento,
  }) async {
    final integrador = await _database.getIntegrador(id);
    await _database.updateIntegrador(
      integrador.copyWith(
        secuencia: secuencia,
        tipo: tipo,
        nombreArchivo: nombreArchivo,
        rutaArchivo: rutaArchivo,
        estado: estado ?? integrador.estado,
        resultado: drift.Value(resultado),
        fechaProcesamiento: drift.Value(fechaProcesamiento),
      ),
    );
    await loadIntegradores();
  }

  Future<void> updateEstadoIntegrador({
    required int id,
    required String estado,
    String? resultado,
  }) async {
    final integrador = await _database.getIntegrador(id);
    await _database.updateIntegrador(
      integrador.copyWith(
        estado: estado,
        resultado: drift.Value(resultado),
        fechaProcesamiento: drift.Value(DateTime.now()),
      ),
    );
    await loadIntegradores();
  }

  Future<void> deleteIntegrador(int id) async {
    await _database.deleteIntegrador(id);
    await loadIntegradores();
  }

  Integrador? getIntegradorById(int id) {
    try {
      return _integradores.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }
}
