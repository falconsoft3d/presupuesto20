import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conceptos_provider.dart';
import '../providers/productos_provider.dart';
import '../providers/presupuestos_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_list_view.dart';
import '../screens/concepto_comentarios_screen.dart';

class ConceptosList extends StatelessWidget {
  final Function(Concepto) onConceptoSelected;
  final VoidCallback onCreateNew;

  const ConceptosList({
    super.key,
    required this.onConceptoSelected,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<ConceptosProvider, ProductosProvider, PresupuestosProvider>(
      builder: (context, conceptosProvider, productosProvider, presupuestosProvider, child) {
        if (conceptosProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GenericListView<Concepto>(
          items: conceptosProvider.conceptos,
          customActions: (concepto) => [
            IconButton(
              icon: const Icon(Icons.comment, size: 18),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ConceptoComentariosScreen(concepto: concepto),
                  ),
                );
              },
              tooltip: 'Comentarios',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
          columns: [
            ColumnConfig(
              label: 'Código',
              width: 120,
              getValue: (concepto) => concepto.codigo,
            ),
            ColumnConfig(
              label: 'Nombre',
              width: 250,
              getValue: (concepto) => concepto.nombre,
            ),
            ColumnConfig(
              label: 'Tipo Recurso',
              width: 150,
              getValue: (concepto) => concepto.tipoRecurso,
            ),
            ColumnConfig(
              label: 'Producto',
              width: 180,
              getValue: (concepto) {
                if (concepto.productoId == null) return '-';
                final producto = productosProvider.getProductoById(concepto.productoId!);
                return producto?.nombre ?? '-';
              },
            ),
            ColumnConfig(
              label: 'Presupuesto',
              width: 180,
              getValue: (concepto) {
                if (concepto.presupuestoId == null) return '-';
                final presupuesto = presupuestosProvider.getPresupuestoById(concepto.presupuestoId!);
                return presupuesto?.nombre ?? '-';
              },
            ),
            ColumnConfig(
              label: 'Cantidad',
              width: 100,
              getValue: (concepto) => concepto.cantidad.toStringAsFixed(2),
            ),
            ColumnConfig(
              label: 'Coste',
              width: 100,
              getValue: (concepto) => '\$${concepto.coste.toStringAsFixed(2)}',
            ),
            ColumnConfig(
              label: 'Importe',
              width: 120,
              getValue: (concepto) => '\$${concepto.importe.toStringAsFixed(2)}',
            ),
          ],
          title: 'Conceptos',
          emptyIcon: 'category',
          emptyMessage: 'No hay conceptos registrados',
          onItemSelected: onConceptoSelected,
          onEdit: onConceptoSelected,
          onDelete: (concepto) async {
            await Provider.of<ConceptosProvider>(context, listen: false)
                .deleteConcepto(concepto.id);
          },
          onCreate: onCreateNew,
          getSearchableFields: (concepto) => [
            concepto.codigo,
            concepto.nombre,
            concepto.tipoRecurso,
          ],
        );
      },
    );
  }
}
