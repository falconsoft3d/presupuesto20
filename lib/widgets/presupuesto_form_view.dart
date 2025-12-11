import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/presupuestos_provider.dart';
import '../providers/companias_provider.dart';
import '../providers/monedas_provider.dart';
import '../providers/estados_provider.dart';
import '../providers/settings_provider.dart';
import '../database/database.dart';

class PresupuestoFormView extends StatefulWidget {
  final Presupuesto? presupuesto;
  final VoidCallback onBack;

  const PresupuestoFormView({
    super.key,
    this.presupuesto,
    required this.onBack,
  });

  @override
  State<PresupuestoFormView> createState() => _PresupuestoFormViewState();
}

class _PresupuestoFormViewState extends State<PresupuestoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  int? _selectedCompaniaId;
  int? _selectedMonedaId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.presupuesto?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.presupuesto?.nombre ?? '');
    _selectedCompaniaId = widget.presupuesto?.companiaId;
    _selectedMonedaId = widget.presupuesto?.monedaId;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.presupuesto != null;
    final settings = context.watch<SettingsProvider>();

    return Consumer2<CompaniasProvider, MonedasProvider>(
      builder: (context, companiasProvider, monedasProvider, child) {
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
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _savePresupuesto,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: Container(
                color: const Color(0xFFF0F0F0),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información básica
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información del Presupuesto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _codigoController,
                                      decoration: const InputDecoration(
                                        labelText: 'Código *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El código es requerido';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nombreController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nombre *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El nombre es requerido';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Referencias
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referencias',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int?>(
                                      value: _selectedCompaniaId,
                                      decoration: const InputDecoration(
                                        labelText: 'Compañía',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('Seleccionar compañía...'),
                                        ),
                                        ...companiasProvider.companias.map((compania) {
                                          return DropdownMenuItem<int?>(
                                            value: compania.id,
                                            child: Text(compania.nombre),
                                          );
                                        }),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCompaniaId = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<int?>(
                                      value: _selectedMonedaId,
                                      decoration: const InputDecoration(
                                        labelText: 'Moneda',
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
                                        setState(() {
                                          _selectedMonedaId = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
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
          ],
        );
      },
    );
  }

  Future<void> _savePresupuesto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final presupuestosProvider = context.read<PresupuestosProvider>();

    try {
      if (widget.presupuesto != null) {
        await presupuestosProvider.updatePresupuesto(
          id: widget.presupuesto!.id,
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          companiaId: _selectedCompaniaId,
          monedaId: _selectedMonedaId,
        );
      } else {
        await presupuestosProvider.createPresupuesto(
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          companiaId: _selectedCompaniaId,
          monedaId: _selectedMonedaId,
        );
      }

      if (mounted) {
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
