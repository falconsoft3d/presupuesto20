import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/empleados_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_list_view.dart';

class EmpleadosList extends StatelessWidget {
  final Function(Empleado) onEmpleadoSelected;
  final VoidCallback onCreateNew;

  const EmpleadosList({
    super.key,
    required this.onEmpleadoSelected,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpleadosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GenericListView<Empleado>(
          items: provider.empleados,
          columns: [
            ColumnConfig(
              label: 'Código',
              width: 150,
              getValue: (empleado) => empleado.codigo,
            ),
            ColumnConfig(
              label: 'Nombre',
              width: 250,
              getValue: (empleado) => empleado.nombre,
            ),
            ColumnConfig(
              label: 'Email',
              width: 200,
              getValue: (empleado) => empleado.email ?? '-',
            ),
            ColumnConfig(
              label: 'Teléfono',
              width: 150,
              getValue: (empleado) => empleado.telefono ?? '-',
            ),
            ColumnConfig(
              label: 'Dirección',
              width: 250,
              getValue: (empleado) => empleado.direccion ?? '-',
            ),
          ],
          title: 'Empleados',
          emptyIcon: 'badge',
          emptyMessage: 'No hay empleados registrados',
          onItemSelected: onEmpleadoSelected,
          onEdit: onEmpleadoSelected,
          onDelete: (empleado) async {
            await Provider.of<EmpleadosProvider>(context, listen: false)
                .deleteEmpleado(empleado.id);
          },
          onCreate: onCreateNew,
          getSearchableFields: (empleado) => [
            empleado.codigo,
            empleado.nombre,
            empleado.email ?? '',
            empleado.telefono ?? '',
          ],
        );
      },
    );
  }
}
