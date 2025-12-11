import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import '../providers/contactos_provider.dart';
import '../database/database.dart';

class ContactoFormView extends StatefulWidget {
  final Contacto? contacto;
  final VoidCallback onBack;

  const ContactoFormView({
    super.key,
    this.contacto,
    required this.onBack,
  });

  @override
  State<ContactoFormView> createState() => _ContactoFormViewState();
}

class _ContactoFormViewState extends State<ContactoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _notasController;
  bool _isSaving = false;
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.contacto?.nombre ?? '');
    _emailController = TextEditingController(text: widget.contacto?.email ?? '');
    _telefonoController = TextEditingController(text: widget.contacto?.telefono ?? '');
    _notasController = TextEditingController(text: widget.contacto?.notas ?? '');
    _fotoPath = widget.contacto?.foto;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contacto != null;

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
              Text(
                isEditing ? _nombreController.text : 'Nuevo Contacto',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ElevatedButton.icon(
                  onPressed: _saveContacto,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
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
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(40),
                                    image: _fotoPath != null && File(_fotoPath!).existsSync()
                                        ? DecorationImage(
                                            image: FileImage(File(_fotoPath!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _fotoPath == null || !File(_fotoPath!).existsSync()
                                      ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey.shade500,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: TextFormField(
                                controller: _nombreController,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Nombre del contacto',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El nombre es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form fields
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Información de Contacto'),
                            const SizedBox(height: 16),
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Email',
                                    controller: _emailController,
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField(
                                    label: 'Teléfono',
                                    controller: _telefonoController,
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Notas'),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _notasController,
                              decoration: InputDecoration(
                                hintText: 'Agregar notas...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              maxLines: 6,
                            ),
                          ],
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null && File(path).existsSync()) {
          setState(() {
            _fotoPath = path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveContacto() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final provider = context.read<ContactosProvider>();
      bool success;

      if (widget.contacto != null) {
        final updatedContacto = widget.contacto!.copyWith(
          nombre: _nombreController.text,
          email: drift.Value(_emailController.text.isEmpty ? null : _emailController.text),
          telefono: drift.Value(_telefonoController.text.isEmpty ? null : _telefonoController.text),
          foto: drift.Value(_fotoPath),
          notas: drift.Value(_notasController.text.isEmpty ? null : _notasController.text),
        );
        success = await provider.updateContacto(updatedContacto);
      } else {
        success = await provider.createContacto(
          nombre: _nombreController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
          foto: _fotoPath,
          notas: _notasController.text.isEmpty ? null : _notasController.text,
        );
      }

      setState(() => _isSaving = false);

      if (mounted) {
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

        if (success) {
          widget.onBack();
        }
      }
    }
  }
}
