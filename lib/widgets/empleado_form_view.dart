import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/empleados_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_form_view.dart';

class EmpleadoFormView extends StatefulWidget {
  final Empleado? empleado;
  final VoidCallback onBack;

  const EmpleadoFormView({
    super.key,
    this.empleado,
    required this.onBack,
  });

  @override
  State<EmpleadoFormView> createState() => _EmpleadoFormViewState();
}

class _EmpleadoFormViewState extends State<EmpleadoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.empleado?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.empleado?.nombre ?? '');
    _emailController = TextEditingController(text: widget.empleado?.email ?? '');
    _telefonoController = TextEditingController(text: widget.empleado?.telefono ?? '');
    _direccionController = TextEditingController(text: widget.empleado?.direccion ?? '');
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.empleado != null;

    return GenericFormView(
      title: 'Empleado',
      isEditing: isEditing,
      formKey: _formKey,
      onBack: widget.onBack,
      onSave: _saveEmpleado,
      sections: [
        SectionConfig(
          title: 'Información del Empleado',
          columns: 2,
          fields: [
            FieldConfig(
              key: 'codigo',
              label: 'Código',
              controller: _codigoController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El código es requerido';
                }
                return null;
              },
            ),
            FieldConfig(
              key: 'nombre',
              label: 'Nombre',
              controller: _nombreController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            FieldConfig(
              key: 'email',
              label: 'Email',
              controller: _emailController,
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
            FieldConfig(
              key: 'telefono',
              label: 'Teléfono',
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        SectionConfig(
          title: 'Dirección',
          columns: 1,
          fields: [
            FieldConfig(
              key: 'direccion',
              label: 'Dirección',
              controller: _direccionController,
              maxLines: 3,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveEmpleado() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final empleadosProvider = context.read<EmpleadosProvider>();

    try {
      if (widget.empleado != null) {
        await empleadosProvider.updateEmpleado(
          id: widget.empleado!.id,
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
          direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
        );
      } else {
        await empleadosProvider.createEmpleado(
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
          direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
        );
      }

      if (mounted) {
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
