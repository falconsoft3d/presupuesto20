import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/integradores_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_list_view.dart';

class IntegradoresList extends StatelessWidget {
  final Function(Integrador) onIntegradorSelected;
  final VoidCallback onCreateNew;

  const IntegradoresList({
    super.key,
    required this.onIntegradorSelected,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<IntegradoresProvider>(
      builder: (context, integradoresProvider, child) {
        if (integradoresProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GenericListView<Integrador>(
          items: integradoresProvider.integradores,
          columns: [
            ColumnConfig(
              label: 'Secuencia',
              width: 120,
              getValue: (integrador) => integrador.secuencia,
            ),
            ColumnConfig(
              label: 'Tipo',
              width: 100,
              getValue: (integrador) => integrador.tipo,
            ),
            ColumnConfig(
              label: 'Archivo',
              width: 250,
              getValue: (integrador) => integrador.nombreArchivo,
            ),
            ColumnConfig(
              label: 'Estado',
              width: 120,
              customWidget: (integrador) {
                Color color;
                switch (integrador.estado) {
                  case 'Procesado':
                    color = Colors.green;
                    break;
                  case 'Error':
                    color = Colors.red;
                    break;
                  default:
                    color = Colors.orange;
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    integrador.estado,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              getValue: (integrador) => integrador.estado,
            ),
            ColumnConfig(
              label: 'Fecha Creación',
              width: 150,
              getValue: (integrador) => DateFormat('dd/MM/yyyy HH:mm').format(integrador.fechaCreacion),
            ),
            ColumnConfig(
              label: 'Fecha Procesamiento',
              width: 150,
              getValue: (integrador) => integrador.fechaProcesamiento != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(integrador.fechaProcesamiento!)
                  : '-',
            ),
          ],
          title: 'Integradores',
          emptyIcon: 'integration_instructions',
          emptyMessage: 'No hay integradores registrados',
          onItemSelected: onIntegradorSelected,
          onEdit: onIntegradorSelected,
          onDelete: (integrador) async {
            await Provider.of<IntegradoresProvider>(context, listen: false)
                .deleteIntegrador(integrador.id);
          },
          onCreate: onCreateNew,
          getSearchableFields: (integrador) => [
            integrador.secuencia,
            integrador.tipo,
            integrador.nombreArchivo,
            integrador.estado,
          ],
        );
      },
    );
  }
}
