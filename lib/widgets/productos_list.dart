import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/productos_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_list_view.dart';

class ProductosList extends StatelessWidget {
  final Function(Producto) onProductoSelected;
  final VoidCallback onCreateNew;

  const ProductosList({
    super.key,
    required this.onProductoSelected,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GenericListView<Producto>(
          items: provider.productos,
          columns: [
            ColumnConfig(
              label: 'Código',
              width: 150,
              getValue: (producto) => producto.codigo,
            ),
            ColumnConfig(
              label: 'Nombre',
              width: 300,
              getValue: (producto) => producto.nombre,
            ),
            ColumnConfig(
              label: 'Tipo de Recurso',
              width: 200,
              getValue: (producto) => producto.tipo,
            ),
            ColumnConfig(
              label: 'Precio',
              width: 150,
              getValue: (producto) => '\$${producto.precio.toStringAsFixed(2)}',
            ),
            ColumnConfig(
              label: 'Coste',
              width: 150,
              getValue: (producto) => '\$${producto.coste.toStringAsFixed(2)}',
            ),
          ],
          title: 'Productos',
          emptyIcon: 'inventory',
          emptyMessage: 'No hay productos registrados',
          onItemSelected: onProductoSelected,
          onEdit: onProductoSelected,
          onDelete: (producto) async {
            await Provider.of<ProductosProvider>(context, listen: false)
                .deleteProducto(producto.id);
          },
          onCreate: onCreateNew,
          getSearchableFields: (producto) => [
            producto.codigo,
            producto.nombre,
            producto.tipo,
          ],
        );
      },
    );
  }
}
