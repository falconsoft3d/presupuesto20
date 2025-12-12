import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/companias_provider.dart';
import '../providers/monedas_provider.dart';
import '../database/database.dart';

class CompaniasScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CompaniasScreen({super.key, required this.onBack});

  @override
  State<CompaniasScreen> createState() => _CompaniasScreenState();
}

class _CompaniasScreenState extends State<CompaniasScreen> {
  Compania? _selectedCompania;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return _selectedCompania != null || _isCreating
        ? _buildFormView()
        : _buildListView();
  }

  Widget _buildListView() {
    return Consumer<CompaniasProvider>(
      builder: (context, provider, child) {
        final filteredCompanias = provider.companias.where((compania) {
          final query = _searchQuery.toLowerCase();
          return compania.nombre.toLowerCase().contains(query) ||
              (compania.razonSocial?.toLowerCase().contains(query) ?? false) ||
              (compania.ruc?.toLowerCase().contains(query) ?? false);
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
                    'Compañías',
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
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
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
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1.5),
                          4: FixedColumnWidth(100),
                          5: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell(''),
                              _buildHeaderCell('Nombre'),
                              _buildHeaderCell('Razón Social'),
                              _buildHeaderCell('RUC/NIT'),
                              _buildHeaderCell('Estado'),
                              _buildHeaderCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Table Body
                    Expanded(
                      child: filteredCompanias.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron compañías',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCompanias.length,
                              itemBuilder: (context, index) {
                                final compania = filteredCompanias[index];
                                
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCompania = compania;
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
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(2),
                                        3: FlexColumnWidth(1.5),
                                        4: FixedColumnWidth(100),
                                        5: FixedColumnWidth(80),
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
                                              compania.nombre,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            )),
                                            _buildDataCell(Text(
                                              compania.razonSocial ?? '-',
                                              style: const TextStyle(fontSize: 13),
                                            )),
                                            _buildDataCell(Text(
                                              compania.ruc ?? '-',
                                              style: const TextStyle(fontSize: 13),
                                            )),
                                            _buildDataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: compania.activa ? Colors.green : Colors.grey,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  compania.activa ? 'Activa' : 'Inactiva',
                                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
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
                                                        _selectedCompania = compania;
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
                                                      final confirmed = await _showDeleteConfirmation(compania.nombre);
                                                      if (confirmed && mounted) {
                                                        final success = await provider.deleteCompania(compania.id);
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                success
                                                                    ? 'Compañía eliminada'
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
    final provider = Provider.of<CompaniasProvider>(context, listen: false);
    final isEditing = _selectedCompania != null;
    
    final nombreController = TextEditingController(
      text: isEditing ? _selectedCompania!.nombre : '',
    );
    final razonSocialController = TextEditingController(
      text: isEditing ? _selectedCompania!.razonSocial : '',
    );
    final rucController = TextEditingController(
      text: isEditing ? _selectedCompania!.ruc : '',
    );
    final direccionController = TextEditingController(
      text: isEditing ? _selectedCompania!.direccion : '',
    );
    final telefonoController = TextEditingController(
      text: isEditing ? _selectedCompania!.telefono : '',
    );
    final emailController = TextEditingController(
      text: isEditing ? _selectedCompania!.email : '',
    );
    final formKey = GlobalKey<FormState>();
    bool activa = isEditing ? _selectedCompania!.activa : true;
    int? monedaId = isEditing ? _selectedCompania!.monedaId : null;

    return StatefulBuilder(
      builder: (context, setFormState) {
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
                        _selectedCompania = null;
                        _isCreating = false;
                      });
                    },
                    tooltip: 'Volver',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Editar Compañía' : 'Nueva Compañía',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      final nombre = nombreController.text.trim();
                      final razonSocial = razonSocialController.text.trim();
                      final ruc = rucController.text.trim();
                      final direccion = direccionController.text.trim();
                      final telefono = telefonoController.text.trim();
                      final email = emailController.text.trim();

                      bool success;
                      if (isEditing) {
                        success = await provider.updateCompania(
                          id: _selectedCompania!.id,
                          nombre: nombre,
                          razonSocial: razonSocial.isEmpty ? null : razonSocial,
                          ruc: ruc.isEmpty ? null : ruc,
                          direccion: direccion.isEmpty ? null : direccion,
                          telefono: telefono.isEmpty ? null : telefono,
                          email: email.isEmpty ? null : email,
                          monedaId: monedaId,
                          activa: activa,
                        );
                      } else {
                        success = await provider.createCompania(
                          nombre: nombre,
                          razonSocial: razonSocial.isEmpty ? null : razonSocial,
                          ruc: ruc.isEmpty ? null : ruc,
                          direccion: direccion.isEmpty ? null : direccion,
                          telefono: telefono.isEmpty ? null : telefono,
                          email: email.isEmpty ? null : email,
                          monedaId: monedaId,
                          activa: activa,
                        );
                      }

                      if (mounted && success) {
                        setState(() {
                          _selectedCompania = null;
                          _isCreating = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing ? 'Compañía actualizada' : 'Compañía creada',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Guardar'),
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
                            controller: nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre *',
                              prefixIcon: Icon(Icons.business),
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
                          TextFormField(
                            controller: razonSocialController,
                            decoration: const InputDecoration(
                              labelText: 'Razón Social',
                              prefixIcon: Icon(Icons.description_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: rucController,
                            decoration: const InputDecoration(
                              labelText: 'RUC/NIT',
                              prefixIcon: Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: direccionController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Ingrese un email válido';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer<MonedasProvider>(
                            builder: (context, monedasProvider, _) {
                              return DropdownButtonFormField<int?>(
                                value: monedaId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Moneda',
                                  prefixIcon: Icon(Icons.monetization_on_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Seleccionar moneda...'),
                                  ),
                                  ...monedasProvider.monedas.map((moneda) {
                                    return DropdownMenuItem<int?>(
                                      value: moneda.id,
                                      child: Text('${moneda.nombre} (${moneda.signo})'),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  monedaId = value;
                                  setFormState(() {});
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Estado'),
                            subtitle: Text(activa ? 'Activa' : 'Inactiva'),
                            value: activa,
                            onChanged: (value) {
                              setFormState(() {
                                activa = value;
                              });
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
      },
    );
  }

  Future<bool> _showDeleteConfirmation(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Eliminar compañía "$nombre"?'),
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
}
