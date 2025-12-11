import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';

class ProductosProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Producto> _productos = [];
  bool _isLoading = false;

  ProductosProvider(this._database) {
    loadProductos();
  }

  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;

  Future<void> loadProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _productos = await _database.getAllProductos();
    } catch (e) {
      debugPrint('Error loading productos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProducto({
    required String codigo,
    required String nombre,
    required String tipo,
    double precio = 0.0,
    double coste = 0.0,
    String? descripcion,
  }) async {
    try {
      final producto = ProductosCompanion(
        codigo: drift.Value(codigo),
        nombre: drift.Value(nombre),
        tipo: drift.Value(tipo),
        precio: drift.Value(precio),
        coste: drift.Value(coste),
        descripcion: drift.Value(descripcion),
        fechaCreacion: drift.Value(DateTime.now()),
        fechaModificacion: drift.Value(DateTime.now()),
      );

      await _database.insertProducto(producto);
      await loadProductos();
    } catch (e) {
      debugPrint('Error creating producto: $e');
      rethrow;
    }
  }

  Future<void> updateProducto(Producto producto) async {
    try {
      final updatedProducto = producto.copyWith(
        fechaModificacion: DateTime.now(),
      );
      await _database.updateProducto(updatedProducto);
      await loadProductos();
    } catch (e) {
      debugPrint('Error updating producto: $e');
      rethrow;
    }
  }

  Future<void> deleteProducto(int id) async {
    try {
      await _database.deleteProducto(id);
      await loadProductos();
    } catch (e) {
      debugPrint('Error deleting producto: $e');
      rethrow;
    }
  }
}
