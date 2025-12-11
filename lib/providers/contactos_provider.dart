import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';

class ContactosProvider with ChangeNotifier {
  final AppDatabase database;
  List<Contacto> _contactos = [];
  bool _isLoading = false;

  ContactosProvider(this.database) {
    loadContactos();
  }

  List<Contacto> get contactos => _contactos;
  bool get isLoading => _isLoading;

  Future<void> loadContactos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contactos = await database.getAllContactos();
    } catch (e) {
      debugPrint('Error loading contactos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createContacto({
    required String nombre,
    String? email,
    String? telefono,
    String? foto,
    String? notas,
  }) async {
    try {
      final contacto = ContactosCompanion(
        nombre: drift.Value(nombre),
        email: drift.Value(email),
        telefono: drift.Value(telefono),
        foto: drift.Value(foto),
        notas: drift.Value(notas),
        fechaCreacion: drift.Value(DateTime.now()),
        fechaModificacion: drift.Value(DateTime.now()),
      );

      await database.insertContacto(contacto);
      await loadContactos();
      return true;
    } catch (e) {
      debugPrint('Error creating contacto: $e');
      return false;
    }
  }

  Future<bool> updateContacto(Contacto contacto) async {
    try {
      final updatedContacto = contacto.copyWith(
        fechaModificacion: DateTime.now(),
      );
      await database.updateContacto(updatedContacto);
      await loadContactos();
      return true;
    } catch (e) {
      debugPrint('Error updating contacto: $e');
      return false;
    }
  }

  Future<bool> deleteContacto(int id) async {
    try {
      await database.deleteContacto(id);
      await loadContactos();
      return true;
    } catch (e) {
      debugPrint('Error deleting contacto: $e');
      return false;
    }
  }

  Contacto? getContactoById(int id) {
    try {
      return _contactos.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
