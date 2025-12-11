import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obras_provider.dart';
import '../database/database.dart';
import 'obra_form_dialog.dart';
import 'package:intl/intl.dart';

class ObrasList extends StatelessWidget {
  const ObrasList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ObrasProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.obras.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay obras registradas',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comienza creando una nueva obra',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ObraFormDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Obra'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ObraFormDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF875A7B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.import_export, size: 18),
                    label: const Text('Importar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 250,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 20),
                    tooltip: 'Filtros',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Table Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FixedColumnWidth(100),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1.5),
                          4: FlexColumnWidth(1.5),
                          5: FixedColumnWidth(120),
                          6: FixedColumnWidth(100),
                          7: FixedColumnWidth(100),
                          8: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell(''),
                              _buildHeaderCell('Código'),
                              _buildHeaderCell('Nombre'),
                              _buildHeaderCell('Cliente'),
                              _buildHeaderCell('Ubicación'),
                              _buildHeaderCell('Presupuesto'),
                              _buildHeaderCell('Estado'),
                              _buildHeaderCell('Fecha Inicio'),
                              _buildHeaderCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Table Body
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.obras.length,
                        itemBuilder: (context, index) {
                          final obra = provider.obras[index];
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => ObraFormDialog(obra: obra),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(40),
                                  1: FixedColumnWidth(100),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(1.5),
                                  4: FlexColumnWidth(1.5),
                                  5: FixedColumnWidth(120),
                                  6: FixedColumnWidth(100),
                                  7: FixedColumnWidth(100),
                                  8: FixedColumnWidth(80),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      _buildDataCell(Checkbox(
                                        value: false,
                                        onChanged: (value) {},
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )),
                                      _buildDataCell(Text(obra.codigo, style: const TextStyle(fontSize: 13))),
                                      _buildDataCell(Text(obra.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                                      _buildDataCell(Text(obra.cliente, style: const TextStyle(fontSize: 13))),
                                      _buildDataCell(Text(obra.ubicacion ?? '-', style: const TextStyle(fontSize: 13))),
                                      _buildDataCell(Text(
                                        NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(obra.presupuestoTotal),
                                        style: const TextStyle(fontSize: 13),
                                      )),
                                      _buildDataCell(_buildEstadoChip(obra.estado)),
                                      _buildDataCell(Text(
                                        obra.fechaInicio != null
                                            ? DateFormat('dd/MM/yyyy').format(obra.fechaInicio!)
                                            : '-',
                                        style: const TextStyle(fontSize: 13),
                                      )),
                                      _buildDataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 16),
                                              tooltip: 'Editar',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => ObraFormDialog(obra: obra),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 16),
                                              tooltip: 'Eliminar',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                _confirmDelete(context, provider, obra);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Footer
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '1-${provider.obras.length} / ${provider.obras.length}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: child,
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    switch (estado) {
      case 'Activa':
        color = Colors.green;
        break;
      case 'En Proceso':
        color = Colors.orange;
        break;
      case 'Finalizada':
        color = Colors.blue;
        break;
      case 'Cancelada':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ObrasProvider provider, Obra obra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la obra "${obra.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteObra(obra.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Obra eliminada correctamente'
                          : 'Error al eliminar la obra',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
