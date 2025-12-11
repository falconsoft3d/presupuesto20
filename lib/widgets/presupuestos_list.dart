import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/presupuestos_provider.dart';
import '../providers/companias_provider.dart';
import '../providers/monedas_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_list_view.dart';

class PresupuestosList extends StatelessWidget {
  final Function(Presupuesto) onPresupuestoSelected;
  final VoidCallback onCreateNew;

  const PresupuestosList({
    super.key,
    required this.onPresupuestoSelected,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<PresupuestosProvider, CompaniasProvider, MonedasProvider>(
      builder: (context, presupuestosProvider, companiasProvider, monedasProvider, child) {
        if (presupuestosProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GenericListView<Presupuesto>(
          items: presupuestosProvider.presupuestos,
          columns: [
            ColumnConfig(
              label: 'Código',
              width: 150,
              getValue: (presupuesto) => presupuesto.codigo,
            ),
            ColumnConfig(
              label: 'Nombre',
              width: 300,
              getValue: (presupuesto) => presupuesto.nombre,
            ),
            ColumnConfig(
              label: 'Compañía',
              width: 200,
              getValue: (presupuesto) {
                if (presupuesto.companiaId == null) return '-';
                final compania = companiasProvider.getCompaniaById(presupuesto.companiaId!);
                return compania?.nombre ?? '-';
              },
            ),
            ColumnConfig(
              label: 'Moneda',
              width: 150,
              getValue: (presupuesto) {
                if (presupuesto.monedaId == null) return '-';
                final moneda = monedasProvider.getMonedaById(presupuesto.monedaId!);
                return moneda?.nombre ?? '-';
              },
            ),
          ],
          title: 'Presupuestos',
          emptyIcon: 'description',
          emptyMessage: 'No hay presupuestos registrados',
          onItemSelected: onPresupuestoSelected,
          onEdit: onPresupuestoSelected,
          onDelete: (presupuesto) async {
            await Provider.of<PresupuestosProvider>(context, listen: false)
                .deletePresupuesto(presupuesto.id);
          },
          onCreate: onCreateNew,
          getSearchableFields: (presupuesto) => [
            presupuesto.codigo,
            presupuesto.nombre,
          ],
        );
      },
    );
  }
}
