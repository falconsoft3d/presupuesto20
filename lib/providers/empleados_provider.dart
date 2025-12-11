import 'package:flutter/foundation.dart';
import '../database/database.dart';
import 'package:drift/drift.dart';

class EmpleadosProvider with ChangeNotifier {
  final AppDatabase database;
  List<Empleado> _empleados = [];
  bool _isLoading = false;

  EmpleadosProvider(this.database) {
    loadEmpleados();
  }

  List<Empleado> get empleados => _empleados;
  bool get isLoading => _isLoading;

  Future<void> loadEmpleados() async {
    _isLoading = true;
    notifyListeners();

    try {
      _empleados = await database.getAllEmpleados();
    } catch (e) {
      debugPrint('Error loading empleados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEmpleado({
    required String nombre,
    String? telefono,
    String? email,
    required String codigo,
    String? direccion,
  }) async {
    try {
      await database.insertEmpleado(
        EmpleadosCompanion(
          nombre: Value(nombre),
          telefono: telefono != null && telefono.isNotEmpty 
              ? Value(telefono) 
              : const Value.absent(),
          email: email != null && email.isNotEmpty 
              ? Value(email) 
              : const Value.absent(),
          codigo: Value(codigo),
          direccion: direccion != null && direccion.isNotEmpty 
              ? Value(direccion) 
              : const Value.absent(),
        ),
      );
      await loadEmpleados();
    } catch (e) {
      debugPrint('Error creating empleado: $e');
      rethrow;
    }
  }

  Future<void> updateEmpleado({
    required int id,
    required String nombre,
    String? telefono,
    String? email,
    required String codigo,
    String? direccion,
  }) async {
    try {
      final empleado = await database.getEmpleado(id);
      await database.updateEmpleado(
        empleado.copyWith(
          nombre: nombre,
          telefono: Value.absentIfNull(telefono),
          email: Value.absentIfNull(email),
          codigo: codigo,
          direccion: Value.absentIfNull(direccion),
          fechaModificacion: DateTime.now(),
        ),
      );
      await loadEmpleados();
    } catch (e) {
      debugPrint('Error updating empleado: $e');
      rethrow;
    }
  }

  Future<void> deleteEmpleado(int id) async {
    try {
      await database.deleteEmpleado(id);
      await loadEmpleados();
    } catch (e) {
      debugPrint('Error deleting empleado: $e');
      rethrow;
    }
  }

  Empleado? getEmpleadoById(int id) {
    try {
      return _empleados.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
