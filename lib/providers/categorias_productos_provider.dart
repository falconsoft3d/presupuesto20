import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class CategoriasProductosProvider with ChangeNotifier {
  final AppDatabase _database;
  List<CategoriaProducto> _categorias = [];
  bool _isLoading = false;

  CategoriasProductosProvider(this._database) {
    loadCategorias();
  }

  List<CategoriaProducto> get categorias => _categorias;
  bool get isLoading => _isLoading;

  Future<void> loadCategorias() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categorias = await _database.getAllCategoriasProductos();
    } catch (e) {
      debugPrint('Error loading categorias productos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategoria({required String nombre}) async {
    try {
      final categoria = CategoriasProductosCompanion.insert(
        nombre: nombre,
      );

      await _database.insertCategoriaProducto(categoria);
      await loadCategorias();
      return true;
    } catch (e) {
      debugPrint('Error creating categoria producto: $e');
      return false;
    }
  }

  Future<bool> updateCategoria({
    required int id,
    required String nombre,
  }) async {
    try {
      final categoriaActual = getCategoriaById(id);
      if (categoriaActual == null) return false;

      final categoria = CategoriaProducto(
        id: id,
        nombre: nombre,
        fechaCreacion: categoriaActual.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );

      await _database.updateCategoriaProducto(categoria);
      await loadCategorias();
      return true;
    } catch (e) {
      debugPrint('Error updating categoria producto: $e');
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    try {
      await _database.deleteCategoriaProducto(id);
      await loadCategorias();
      return true;
    } catch (e) {
      debugPrint('Error deleting categoria producto: $e');
      return false;
    }
  }

  CategoriaProducto? getCategoriaById(int id) {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
