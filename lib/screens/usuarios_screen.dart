import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usuarios_provider.dart';
import '../database/database.dart';

class UsuariosScreen extends StatefulWidget {
  final VoidCallback onBack;

  const UsuariosScreen({super.key, required this.onBack});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  Usuario? _selectedUsuario;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return _selectedUsuario != null || _isCreating
        ? _buildFormView()
        : _buildListView();
  }

  Widget _buildListView() {
    return Consumer<UsuariosProvider>(
      builder: (context, provider, child) {
        final filteredUsuarios = provider.usuarios.where((usuario) {
          final query = _searchQuery.toLowerCase();
          return usuario.nombre.toLowerCase().contains(query) ||
              usuario.email.toLowerCase().contains(query);
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
                    'Usuarios',
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
                        2: FlexColumnWidth(2.5),
                        3: FlexColumnWidth(1.2),
                        4: FlexColumnWidth(1.5),
                        5: FixedColumnWidth(80),
                      },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell(''),
                              _buildHeaderCell('Nombre'),
                              _buildHeaderCell('Email'),
                              _buildHeaderCell('Perfil'),
                              _buildHeaderCell('Fecha Creación'),
                              _buildHeaderCell(''),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Table Body
                    Expanded(
                      child: filteredUsuarios.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron usuarios',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredUsuarios.length,
                              itemBuilder: (context, index) {
                                final usuario = filteredUsuarios[index];
                                final fecha = usuario.fechaCreacion;
                                final fechaStr = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                                
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedUsuario = usuario;
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
                                        2: FlexColumnWidth(2.5),
                                        3: FlexColumnWidth(1.2),
                                        4: FlexColumnWidth(1.5),
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
                                              usuario.nombre,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                            )),
                                            _buildDataCell(Text(
                                              usuario.email,
                                              style: const TextStyle(fontSize: 13),
                                            )),
                                            _buildDataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: usuario.perfil == 'administrador' 
                                                      ? Colors.purple.shade100 
                                                      : Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  usuario.perfil == 'administrador' ? 'Admin' : 'Usuario',
                                                  style: TextStyle(
                                                    color: usuario.perfil == 'administrador' 
                                                        ? Colors.purple.shade900 
                                                        : Colors.blue.shade900,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
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
                                                        _selectedUsuario = usuario;
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
                                                      final confirmed = await _showDeleteConfirmation(usuario.nombre);
                                                      if (confirmed && mounted) {
                                                        final success = await provider.deleteUsuario(usuario.id);
                                                        if (mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                success
                                                                    ? 'Usuario eliminado'
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
    final provider = Provider.of<UsuariosProvider>(context, listen: false);
    final isEditing = _selectedUsuario != null;
    
    final nameController = TextEditingController(
      text: isEditing ? _selectedUsuario!.nombre : '',
    );
    final emailController = TextEditingController(
      text: isEditing ? _selectedUsuario!.email : '',
    );
    final passwordController = TextEditingController();
    String perfilSeleccionado = isEditing ? _selectedUsuario!.perfil : 'administrador';
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
                    _selectedUsuario = null;
                    _isCreating = false;
                  });
                },
                tooltip: 'Volver',
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
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
                  final email = emailController.text.trim();
                  final password = passwordController.text;

                  bool success;
                  if (isEditing) {
                    success = await provider.updateUsuario(
                      id: _selectedUsuario!.id,
                      nombre: nombre,
                      email: email,
                      newPassword: password.isEmpty ? null : password,
                      perfil: perfilSeleccionado,
                    );
                  } else {
                    success = await provider.createUsuario(
                      nombre: nombre,
                      email: email,
                      password: password,
                      perfil: perfilSeleccionado,
                    );
                  }

                  if (mounted && success) {
                    setState(() {
                      _selectedUsuario = null;
                      _isCreating = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing ? 'Usuario actualizado' : 'Usuario creado',
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
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          prefixIcon: Icon(Icons.person_outline),
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
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El email es obligatorio';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Ingrese un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: isEditing 
                              ? 'Nueva Contraseña (opcional)' 
                              : 'Contraseña *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (!isEditing && (value == null || value.isEmpty)) {
                            return 'La contraseña es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: perfilSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Perfil *',
                          prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'administrador',
                            child: Text('Administrador'),
                          ),
                          DropdownMenuItem(
                            value: 'usuario',
                            child: Text('Usuario'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            perfilSeleccionado = value;
                          }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            content: Text('¿Eliminar usuario "$nombre"?'),
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
