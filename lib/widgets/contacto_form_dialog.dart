import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/contactos_provider.dart';
import '../database/database.dart';

class ContactoFormDialog extends StatefulWidget {
  final Contacto? contacto;

  const ContactoFormDialog({super.key, this.contacto});

  @override
  State<ContactoFormDialog> createState() => _ContactoFormDialogState();
}

class _ContactoFormDialogState extends State<ContactoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _empresaController;
  late TextEditingController _cargoController;
  late TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.contacto?.nombre ?? '');
    _emailController = TextEditingController(text: widget.contacto?.email ?? '');
    _telefonoController = TextEditingController(text: widget.contacto?.telefono ?? '');
    _empresaController = TextEditingController(text: widget.contacto?.empresa ?? '');
    _cargoController = TextEditingController(text: widget.contacto?.cargo ?? '');
    _notasController = TextEditingController(text: widget.contacto?.notas ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _empresaController.dispose();
    _cargoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contacto != null;

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF875A7B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.contacts, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Contacto' : 'Nuevo Contacto',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _empresaController,
                              decoration: const InputDecoration(
                                labelText: 'Empresa',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cargoController,
                              decoration: const InputDecoration(
                                labelText: 'Cargo',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _notasController,
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveContacto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF875A7B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(isEditing ? 'Guardar' : 'Crear'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveContacto() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ContactosProvider>();
      bool success;

      if (widget.contacto != null) {
        final updatedContacto = widget.contacto!.copyWith(
          nombre: _nombreController.text,
          email: drift.Value(_emailController.text.isEmpty ? null : _emailController.text),
          telefono: drift.Value(_telefonoController.text.isEmpty ? null : _telefonoController.text),
          empresa: drift.Value(_empresaController.text.isEmpty ? null : _empresaController.text),
          cargo: drift.Value(_cargoController.text.isEmpty ? null : _cargoController.text),
          notas: drift.Value(_notasController.text.isEmpty ? null : _notasController.text),
        );
        success = await provider.updateContacto(updatedContacto);
      } else {
        success = await provider.createContacto(
          nombre: _nombreController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
          empresa: _empresaController.text.isEmpty ? null : _empresaController.text,
          cargo: _cargoController.text.isEmpty ? null : _cargoController.text,
          notas: _notasController.text.isEmpty ? null : _notasController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? widget.contacto != null
                      ? 'Contacto actualizado correctamente'
                      : 'Contacto creado correctamente'
                  : 'Error al guardar el contacto',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
