import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contactos_provider.dart';
import '../database/database.dart';

class ContactosList extends StatefulWidget {
  final Function(Contacto) onContactoSelected;
  final VoidCallback onCreateNew;

  const ContactosList({
    super.key,
    required this.onContactoSelected,
    required this.onCreateNew,
  });

  @override
  State<ContactosList> createState() => _ContactosListState();
}

class _ContactosListState extends State<ContactosList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactosProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.contactos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.contacts_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay contactos registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comienza creando un nuevo contacto',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: widget.onCreateNew,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Contacto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
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
                  ElevatedButton(
                    onPressed: widget.onCreateNew,
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
                    'Contactos',
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
                      controller: _searchController,
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
                                    _searchController.clear();
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
                          4: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell(''),
                              _buildHeaderCell('Nombre'),
                              _buildHeaderCell('Email'),
                              _buildHeaderCell('Teléfono'),
                              _buildHeaderCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Table Body
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final filteredContactos = provider.contactos.where((contacto) {
                            if (_searchQuery.isEmpty) return true;
                            final nombre = contacto.nombre.toLowerCase();
                            final email = (contacto.email ?? '').toLowerCase();
                            final telefono = (contacto.telefono ?? '').toLowerCase();
                            
                            return nombre.contains(_searchQuery) ||
                                   email.contains(_searchQuery) ||
                                   telefono.contains(_searchQuery);
                          }).toList();

                          if (filteredContactos.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron contactos',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredContactos.length,
                            itemBuilder: (context, index) {
                              final contacto = filteredContactos[index];
                              return InkWell(
                                onTap: () => widget.onContactoSelected(contacto),
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
                                  4: FixedColumnWidth(80),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      _buildDataCell(Checkbox(
                                        value: false,
                                        onChanged: (value) {},
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )),
                                      _buildDataCell(Text(contacto.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                                      _buildDataCell(Text(contacto.email ?? '-', style: const TextStyle(fontSize: 13))),
                                      _buildDataCell(Text(contacto.telefono ?? '-', style: const TextStyle(fontSize: 13))),
                                      _buildDataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 16),
                                              tooltip: 'Editar',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => widget.onContactoSelected(contacto),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 16),
                                              tooltip: 'Eliminar',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                _confirmDelete(context, provider, contacto);
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
                          );
                        },
                      ),
                    ),
                    
                    // Footer
                    Builder(
                      builder: (context) {
                        final filteredCount = provider.contactos.where((contacto) {
                          if (_searchQuery.isEmpty) return true;
                          final nombre = contacto.nombre.toLowerCase();
                          final email = (contacto.email ?? '').toLowerCase();
                          final telefono = (contacto.telefono ?? '').toLowerCase();
                          
                          return nombre.contains(_searchQuery) ||
                                 email.contains(_searchQuery) ||
                                 telefono.contains(_searchQuery);
                        }).length;

                        return Container(
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
                                _searchQuery.isEmpty
                                    ? '1-${provider.contactos.length} / ${provider.contactos.length}'
                                    : '$filteredCount de ${provider.contactos.length}',
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
                        );
                      },
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

  void _confirmDelete(BuildContext context, ContactosProvider provider, Contacto contacto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el contacto "${contacto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteContacto(contacto.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Contacto eliminado correctamente'
                          : 'Error al eliminar el contacto',
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
