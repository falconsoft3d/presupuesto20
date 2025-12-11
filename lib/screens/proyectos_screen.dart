import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proyectos_provider.dart';
import '../providers/contactos_provider.dart';
import '../providers/estados_provider.dart';
import '../database/database.dart';

class ProyectosScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ProyectosScreen({super.key, required this.onBack});

  @override
  State<ProyectosScreen> createState() => _ProyectosScreenState();
}

class _ProyectosScreenState extends State<ProyectosScreen> {
  Proyecto? _selectedProyecto;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return _selectedProyecto != null || _isCreating
        ? _buildFormView()
        : _buildListView();
  }

  Widget _buildListView() {
    return Consumer3<ProyectosProvider, ContactosProvider, EstadosProvider>(
      builder: (context, provider, contactosProvider, estadosProvider, child) {
        final filteredProyectos = provider.proyectos.where((proyecto) {
          final query = _searchQuery.toLowerCase();
          return proyecto.codigo.toLowerCase().contains(query) ||
              proyecto.nombre.toLowerCase().contains(query);
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: widget.onBack,
                    tooltip: 'Volver',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isCreating = true;
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
                    'Proyectos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 250,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade400),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, size: 18, color: Colors.grey.shade600),
                      onPressed: () {},
                      tooltip: 'Filtros',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
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
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(3),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(1.5),
                          5: FlexColumnWidth(2),
                          6: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell(''),
                              _buildHeaderCell('Código'),
                              _buildHeaderCell('Nombre'),
                              _buildHeaderCell('Cliente'),
                              _buildHeaderCell('Estado'),
                              _buildHeaderCell('Fecha Creación'),
                              _buildHeaderCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Table Body
                    Expanded(
                      child: filteredProyectos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron proyectos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredProyectos.length,
                              itemBuilder: (context, index) {
                                final proyecto = filteredProyectos[index];
                                final fecha = proyecto.fechaCreacion;
                                final fechaStr = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                                
                                // Obtener nombre del cliente
                                String clienteNombre = '-';
                                if (proyecto.clienteId != null) {
                                  final cliente = contactosProvider.getContactoById(proyecto.clienteId!);
                                  if (cliente != null) {
                                    clienteNombre = cliente.nombre;
                                  }
                                }
                                
                                // Obtener nombre del estado
                                String estadoNombre = '-';
                                if (proyecto.estadoId != null) {
                                  final estado = estadosProvider.getEstadoById(proyecto.estadoId!);
                                  if (estado != null) {
                                    estadoNombre = estado.nombre;
                                  }
                                }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedProyecto = proyecto;
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
                                        1: FlexColumnWidth(1.5),
                                        2: FlexColumnWidth(3),
                                        3: FlexColumnWidth(2),
                                        4: FlexColumnWidth(1.5),
                                        5: FlexColumnWidth(2),
                                        6: FixedColumnWidth(80),
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
                                              proyecto.codigo,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            )),
                                            _buildDataCell(Text(
                                              proyecto.nombre,
                                              style: const TextStyle(fontSize: 13),
                                            )),
                                            _buildDataCell(Text(
                                              clienteNombre,
                                              style: const TextStyle(fontSize: 13),
                                            )),
                                            _buildDataCell(Text(
                                              estadoNombre,
                                              style: const TextStyle(fontSize: 13),
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
                                                        _selectedProyecto = proyecto;
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
                                                      final confirmed = await _showDeleteConfirmation(proyecto.nombre);
                                                      if (confirmed && mounted) {
                                                        final success = await provider.deleteProyecto(proyecto.id);
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                success
                                                                    ? 'Proyecto eliminado'
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
    final provider = context.read<ProyectosProvider>();
    final contactosProvider = context.watch<ContactosProvider>();
    final estadosProvider = context.watch<EstadosProvider>();
    final isEditing = _selectedProyecto != null;
    
    final codigoController = TextEditingController(
      text: isEditing ? _selectedProyecto!.codigo : '',
    );
    final nombreController = TextEditingController(
      text: isEditing ? _selectedProyecto!.nombre : '',
    );
    int? selectedClienteId = isEditing ? _selectedProyecto!.clienteId : null;
    int? selectedEstadoId = isEditing ? _selectedProyecto!.estadoId : null;
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
                    _selectedProyecto = null;
                    _isCreating = false;
                  });
                },
                tooltip: 'Volver',
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final codigo = codigoController.text.trim();
                  final nombre = nombreController.text.trim();

                  bool success;
                  if (isEditing) {
                    success = await provider.updateProyecto(
                      id: _selectedProyecto!.id,
                      codigo: codigo,
                      nombre: nombre,
                      clienteId: selectedClienteId,
                      estadoId: selectedEstadoId,
                    );
                  } else {
                    success = await provider.createProyecto(
                      codigo: codigo,
                      nombre: nombre,
                      clienteId: selectedClienteId,
                      estadoId: selectedEstadoId,
                    );
                  }

                  if (mounted && success) {
                    setState(() {
                      _selectedProyecto = null;
                      _isCreating = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Proyecto actualizado' : 'Proyecto creado',
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
                        controller: codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código *',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El código es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          prefixIcon: Icon(Icons.account_tree),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedClienteId,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Sin cliente'),
                          ),
                          ...contactosProvider.contactos.map((contacto) {
                            return DropdownMenuItem<int>(
                              value: contacto.id,
                              child: Text(contacto.nombre),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          selectedClienteId = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedEstadoId,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Sin estado'),
                          ),
                          ...estadosProvider.estados.map((estado) {
                            return DropdownMenuItem<int>(
                              value: estado.id,
                              child: Text(estado.nombre),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          selectedEstadoId = value;
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
            content: Text('¿Eliminar proyecto "$nombre"?'),
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
