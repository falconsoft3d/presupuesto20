import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estados_provider.dart';
import '../database/database.dart';

class EstadosScreen extends StatefulWidget {
  const EstadosScreen({super.key});

  @override
  State<EstadosScreen> createState() => _EstadosScreenState();
}

class _EstadosScreenState extends State<EstadosScreen> {
  Estado? _selectedEstado;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return _selectedEstado != null || _isCreating
        ? _buildFormView()
        : _buildListView();
  }

  Widget _buildListView() {
    return Consumer<EstadosProvider>(
      builder: (context, provider, child) {
        final filteredEstados = provider.estados.where((estado) {
          final query = _searchQuery.toLowerCase();
          return estado.nombre.toLowerCase().contains(query);
        }).toList();

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
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isCreating = true;
                        _selectedEstado = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      elevation: 0,
                      minimumSize: const Size(36, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Estados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, size: 20),
                    onPressed: () {},
                    tooltip: 'Filtros',
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
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(2),
                          3: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell(''),
                              _buildHeaderCell('Nombre'),
                              _buildHeaderCell('Fecha Creación'),
                              _buildHeaderCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Table Body
                    Expanded(
                      child: filteredEstados.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron estados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredEstados.length,
                              itemBuilder: (context, index) {
                                final estado = filteredEstados[index];
                                final fecha = estado.fechaCreacion;
                                final fechaStr = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedEstado = estado;
                                    });
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
                                        1: FlexColumnWidth(3),
                                        2: FlexColumnWidth(2),
                                        3: FixedColumnWidth(80),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            _buildDataCell(Checkbox(
                                              value: false,
                                              onChanged: (value) {},
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            )),
                                            _buildDataCell(Text(
                                              estado.nombre,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            )),
                                            _buildDataCell(Text(
                                              fechaStr,
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
                                                      setState(() {
                                                        _selectedEstado = estado;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, size: 16),
                                                    tooltip: 'Eliminar',
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () async {
                                                      final confirmed = await _showDeleteConfirmation(estado.nombre);
                                                      if (confirmed && mounted) {
                                                        final success = await provider.deleteEstado(estado.id);
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                success
                                                                    ? 'Estado eliminado'
                                                                    : 'Error al eliminar',
                                                              ),
                                                              backgroundColor: success ? Colors.green : Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      }
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
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormView() {
    final provider = context.read<EstadosProvider>();
    final isEditing = _selectedEstado != null;
    
    final nameController = TextEditingController(
      text: isEditing ? _selectedEstado!.nombre : '',
    );
    final formKey = GlobalKey<FormState>();

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
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedEstado = null;
                    _isCreating = false;
                  });
                },
                tooltip: 'Volver',
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Editar Estado' : 'Nuevo Estado',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final nombre = nameController.text.trim();

                  bool success;
                  if (isEditing) {
                    success = await provider.updateEstado(
                      id: _selectedEstado!.id,
                      nombre: nombre,
                    );
                  } else {
                    success = await provider.createEstado(
                      nombre: nombre,
                    );
                  }

                  if (mounted && success) {
                    setState(() {
                      _selectedEstado = null;
                      _isCreating = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Estado actualizado' : 'Estado creado',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A085),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Form Content
        Expanded(
          child: Container(
            color: const Color(0xFFF0F0F0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }

  Future<bool> _showDeleteConfirmation(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Eliminar estado "$nombre"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
