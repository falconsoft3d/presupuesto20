import 'package:flutter/material.dart';
import '../database/database.dart';
import '../widgets/productos_list.dart';
import '../widgets/producto_form_view.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  Producto? _selectedProducto;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return ProductoFormView(
        producto: _selectedProducto,
        onBack: () {
          setState(() {
            _showForm = false;
            _selectedProducto = null;
          });
        },
      );
    }

    return ProductosList(
      onProductoSelected: (producto) {
        setState(() {
          _selectedProducto = producto;
          _showForm = true;
        });
      },
      onCreateNew: () {
        setState(() {
          _selectedProducto = null;
          _showForm = true;
        });
      },
    );
  }
}
