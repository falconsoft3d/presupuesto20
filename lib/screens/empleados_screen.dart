import 'package:flutter/material.dart';
import '../database/database.dart';
import '../widgets/empleados_list.dart';
import '../widgets/empleado_form_view.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  Empleado? _selectedEmpleado;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return EmpleadoFormView(
        empleado: _selectedEmpleado,
        onBack: () {
          setState(() {
            _showForm = false;
            _selectedEmpleado = null;
          });
        },
      );
    }

    return EmpleadosList(
      onEmpleadoSelected: (empleado) {
        setState(() {
          _selectedEmpleado = empleado;
          _showForm = true;
        });
      },
      onCreateNew: () {
        setState(() {
          _selectedEmpleado = null;
          _showForm = true;
        });
      },
    );
  }
}
