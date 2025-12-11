import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usuarios_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_list_view.dart';
import '../widgets/common/generic_form_view.dart';

class UsuariosScreen extends StatefulWidget {
  final VoidCallback onBack;

  const UsuariosScreen({super.key, required this.onBack});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  Usuario? _selectedUsuario;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return _selectedUsuario != null || _isCreating
        ? _buildFormView()
        : _buildListView();
  }

  Widget _buildListView() {
    return Consumer<UsuariosProvider>(
      builder: (context, provider, child) {
        return GenericListView(
          title: 'Usuarios',
          emptyIcon: 'people',
          emptyMessage: 'No hay usuarios registrados',
          items: provider.usuarios,
          columns: [
            ColumnConfig(
              label: 'Nombre',
              width: 200,
              getValue: (item) => (item as Usuario).nombre,
            ),
            ColumnConfig(
              label: 'Email',
              width: 250,
              getValue: (item) => (item as Usuario).email,
            ),
            ColumnConfig(
              label: 'Fecha de creación',
              width: 180,
              getValue: (item) {
                final usuario = item as Usuario;
                final fecha = usuario.fechaCreacion;
                return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
              },
            ),
            ColumnConfig(
              label: 'Último acceso',
              width: 180,
              getValue: (item) {
                final usuario = item as Usuario;
                if (usuario.ultimoAcceso == null) return 'Nunca';
                final fecha = usuario.ultimoAcceso!;
                return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
              },
            ),
          ],
          onItemSelected: (item) {
            setState(() {
              _selectedUsuario = item as Usuario;
            });
          },
          onCreate: () {
            setState(() {
              _isCreating = true;
            });
          },
          onEdit: (item) {
            setState(() {
              _selectedUsuario = item as Usuario;
            });
          },
          onDelete: (item) async {
            final usuario = item as Usuario;
            final confirmed = await _showDeleteConfirmation(usuario.nombre);
            if (confirmed) {
              final success = await provider.deleteUsuario(usuario.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Usuario eliminado correctamente'
                          : 'Error al eliminar el usuario',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            }
          },
          getSearchableFields: (item) {
            final usuario = item as Usuario;
            return [usuario.nombre, usuario.email];
          },
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
                    );
                  } else {
                    success = await provider.createUsuario(
                      nombre: nombre,
                      email: email,
                      password: password,
                    );
                  }

                  if (mounted) {
                    if (success) {
                      setState(() {
                        _selectedUsuario = null;
                        _isCreating = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Usuario actualizado correctamente'
                                : 'Usuario creado correctamente',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Error al actualizar el usuario'
                                : 'Error al crear el usuario',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
                          labelText: 'Nombre',
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
                          labelText: 'Email',
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
                              ? 'Nueva Contraseña (dejar vacío para no cambiar)' 
                              : 'Contraseña',
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

  Future<bool> _showDeleteConfirmation(String nombre) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Está seguro que desea eliminar el usuario "$nombre"?'),
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
