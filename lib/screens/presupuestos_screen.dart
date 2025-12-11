import 'package:flutter/material.dart';
import '../database/database.dart';
import '../widgets/presupuestos_list.dart';
import '../widgets/presupuesto_form_view.dart';

class PresupuestosScreen extends StatefulWidget {
  const PresupuestosScreen({super.key});

  @override
  State<PresupuestosScreen> createState() => _PresupuestosScreenState();
}

class _PresupuestosScreenState extends State<PresupuestosScreen> {
  Presupuesto? _selectedPresupuesto;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return PresupuestoFormView(
        presupuesto: _selectedPresupuesto,
        onBack: () {
          setState(() {
            _showForm = false;
            _selectedPresupuesto = null;
          });
        },
      );
    }

    return PresupuestosList(
      onPresupuestoSelected: (presupuesto) {
        setState(() {
          _selectedPresupuesto = presupuesto;
          _showForm = true;
        });
      },
      onCreateNew: () {
        setState(() {
          _selectedPresupuesto = null;
          _showForm = true;
        });
      },
    );
  }
}
