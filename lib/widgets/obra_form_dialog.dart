import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../providers/obras_provider.dart';
import 'package:intl/intl.dart';

class ObraFormDialog extends StatefulWidget {
  final Obra? obra;

  const ObraFormDialog({super.key, this.obra});

  @override
  State<ObraFormDialog> createState() => _ObraFormDialogState();
}

class _ObraFormDialogState extends State<ObraFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _clienteController;
  late TextEditingController _ubicacionController;
  late TextEditingController _presupuestoController;
  late TextEditingController _notasController;
  
  String _estadoSeleccionado = 'Activa';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  
  final List<String> _estados = ['Activa', 'En Proceso', 'Finalizada', 'Cancelada'];

  @override
  void initState() {
    super.initState();
    
    _codigoController = TextEditingController(text: widget.obra?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.obra?.nombre ?? '');
    _clienteController = TextEditingController(text: widget.obra?.cliente ?? '');
    _ubicacionController = TextEditingController(text: widget.obra?.ubicacion ?? '');
    _presupuestoController = TextEditingController(
      text: widget.obra?.presupuestoTotal.toString() ?? '0.0',
    );
    _notasController = TextEditingController(text: widget.obra?.notas ?? '');
    
    if (widget.obra != null) {
      _estadoSeleccionado = widget.obra!.estado;
      _fechaInicio = widget.obra!.fechaInicio;
      _fechaFin = widget.obra!.fechaFin;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _clienteController.dispose();
    _ubicacionController.dispose();
    _presupuestoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.obra != null;
    
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0078D4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_work, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Obra' : 'Nueva Obra',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _codigoController,
                              label: 'Código',
                              hint: 'OB-001',
                              icon: Icons.tag,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre de la Obra',
                        hint: 'Construcción de edificio',
                        icon: Icons.business,
                        required: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _clienteController,
                        label: 'Cliente',
                        hint: 'Nombre del cliente',
                        icon: Icons.person,
                        required: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _ubicacionController,
                        label: 'Ubicación',
                        hint: 'Dirección de la obra',
                        icon: Icons.location_on,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _presupuestoController,
                        label: 'Presupuesto Total',
                        hint: '0.00',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Fecha Inicio',
                              date: _fechaInicio,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaInicio ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _fechaInicio = date;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              label: 'Fecha Fin',
                              date: _fechaFin,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaFin ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _fechaFin = date;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _notasController,
                        label: 'Notas',
                        hint: 'Observaciones adicionales',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer with actions
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
                  ElevatedButton.icon(
                    onPressed: _saveObra,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Actualizar' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0078D4), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            const Text(
              'Estado',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _estadoSeleccionado,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0078D4), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: _estados.map((estado) {
            return DropdownMenuItem(
              value: estado,
              child: Text(estado),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _estadoSeleccionado = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy').format(date)
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveObra() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ObrasProvider>();
    
    final presupuesto = double.tryParse(_presupuestoController.text) ?? 0.0;
    
    bool success;
    
    if (widget.obra != null) {
      // Actualizar obra existente
      final obraActualizada = widget.obra!.copyWith(
        codigo: _codigoController.text,
        nombre: _nombreController.text,
        cliente: _clienteController.text,
        ubicacion: drift.Value(_ubicacionController.text.isEmpty ? null : _ubicacionController.text),
        presupuestoTotal: presupuesto,
        estado: _estadoSeleccionado,
        fechaInicio: drift.Value(_fechaInicio),
        fechaFin: drift.Value(_fechaFin),
        notas: drift.Value(_notasController.text.isEmpty ? null : _notasController.text),
        fechaModificacion: DateTime.now(),
      );
      success = await provider.updateObra(obraActualizada);
    } else {
      // Crear nueva obra
      final nuevaObra = ObrasCompanion(
        codigo: drift.Value(_codigoController.text),
        nombre: drift.Value(_nombreController.text),
        cliente: drift.Value(_clienteController.text),
        ubicacion: drift.Value(_ubicacionController.text.isEmpty ? null : _ubicacionController.text),
        presupuestoTotal: drift.Value(presupuesto),
        estado: drift.Value(_estadoSeleccionado),
        fechaInicio: drift.Value(_fechaInicio),
        fechaFin: drift.Value(_fechaFin),
        notas: drift.Value(_notasController.text.isEmpty ? null : _notasController.text),
      );
      success = await provider.addObra(nuevaObra);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.obra != null
                  ? 'Obra actualizada correctamente'
                  : 'Obra creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la obra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
