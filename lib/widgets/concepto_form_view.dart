import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conceptos_provider.dart';
import '../providers/productos_provider.dart';
import '../providers/presupuestos_provider.dart';
import '../providers/settings_provider.dart';
import '../database/database.dart';
import '../screens/concepto_comentarios_screen.dart';

class ConceptoFormView extends StatefulWidget {
  final Concepto? concepto;
  final VoidCallback onBack;

  const ConceptoFormView({
    super.key,
    this.concepto,
    required this.onBack,
  });

  @override
  State<ConceptoFormView> createState() => _ConceptoFormViewState();
}

class _ConceptoFormViewState extends State<ConceptoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late TextEditingController _costeController;
  late TextEditingController _importeController;
  late TextEditingController _rendimientoController;
  
  int? _selectedProductoId;
  int? _selectedPadreId;
  int? _selectedPresupuestoId;
  String _selectedTipoRecurso = 'Capítulo';
  
  final List<String> _tiposRecurso = [
    'Capítulo',
    'Partida',
    'Material',
    'Servicio',
    'Mano de obra',
    'Equipo',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.concepto?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.concepto?.nombre ?? '');
    _cantidadController = TextEditingController(
      text: widget.concepto?.cantidad.toString() ?? '0',
    );
    _costeController = TextEditingController(
      text: widget.concepto?.coste.toString() ?? '0',
    );
    _importeController = TextEditingController(
      text: widget.concepto?.importe.toString() ?? '0',
    );
    _rendimientoController = TextEditingController(
      text: widget.concepto?.rendimiento.toString() ?? '0',
    );
    
    if (widget.concepto != null) {
      _selectedProductoId = widget.concepto!.productoId;
      _selectedPadreId = widget.concepto!.padreId;
      _selectedPresupuestoId = widget.concepto!.presupuestoId;
      _selectedTipoRecurso = widget.concepto!.tipoRecurso;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _cantidadController.dispose();
    _costeController.dispose();
    _importeController.dispose();
    _rendimientoController.dispose();
    super.dispose();
  }

  Future<void> _saveConcepto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ConceptosProvider>();

    try {
      if (widget.concepto != null) {
        // Actualizar
        await provider.updateConcepto(
          id: widget.concepto!.id,
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          cantidad: double.tryParse(_cantidadController.text) ?? 0.0,
          coste: double.tryParse(_costeController.text) ?? 0.0,
          importe: double.tryParse(_importeController.text) ?? 0.0,
          rendimiento: double.tryParse(_rendimientoController.text) ?? 0.0,
          productoId: _selectedProductoId,
          padreId: _selectedPadreId,
          presupuestoId: _selectedPresupuestoId,
          tipoRecurso: _selectedTipoRecurso,
        );
      } else {
        // Crear
        await provider.createConcepto(
          codigo: _codigoController.text,
          nombre: _nombreController.text,
          cantidad: double.tryParse(_cantidadController.text) ?? 0.0,
          coste: double.tryParse(_costeController.text) ?? 0.0,
          importe: double.tryParse(_importeController.text) ?? 0.0,
          rendimiento: double.tryParse(_rendimientoController.text) ?? 0.0,
          productoId: _selectedProductoId,
          padreId: _selectedPadreId,
          presupuestoId: _selectedPresupuestoId,
          tipoRecurso: _selectedTipoRecurso,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.concepto != null
                ? 'Concepto actualizado correctamente'
                : 'Concepto creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<SettingsProvider>().themeColor;
    final isEditing = widget.concepto != null;

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
              if (isEditing) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    widget.concepto!.codigo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.concepto!.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else
                const Text(
                  'Nuevo Concepto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveConcepto,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                            'Información del Concepto',
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
                                flex: 2,
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cantidadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _costeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Coste',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _importeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Importe',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _rendimientoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Rendimiento',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const Expanded(flex: 2, child: SizedBox()),
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
                          DropdownButtonFormField<String>(
                            value: _selectedTipoRecurso,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Recurso *',
                              border: OutlineInputBorder(),
                            ),
                            items: _tiposRecurso.map((tipo) {
                              return DropdownMenuItem<String>(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTipoRecurso = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<ProductosProvider>(
                                  builder: (context, productosProvider, child) {
                                    return DropdownButtonFormField<int?>(
                                      value: _selectedProductoId,
                                      decoration: const InputDecoration(
                                        labelText: 'Producto',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          key: ValueKey('producto-null'),
                                          value: null,
                                          child: Text('Sin producto'),
                                        ),
                                        ...productosProvider.productos.map((producto) {
                                          return DropdownMenuItem<int?>(
                                            key: ValueKey('producto-${producto.id}'),
                                            value: producto.id,
                                            child: Text('${producto.codigo} - ${producto.nombre}'),
                                          );
                                        }),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedProductoId = value;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Consumer<PresupuestosProvider>(
                                  builder: (context, presupuestosProvider, child) {
                                    return DropdownButtonFormField<int?>(
                                      value: _selectedPresupuestoId,
                                      decoration: const InputDecoration(
                                        labelText: 'Presupuesto',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          key: ValueKey('presupuesto-null'),
                                          value: null,
                                          child: Text('Sin presupuesto'),
                                        ),
                                        ...presupuestosProvider.presupuestos.map((presupuesto) {
                                          return DropdownMenuItem<int?>(
                                            key: ValueKey('presupuesto-${presupuesto.id}'),
                                            value: presupuesto.id,
                                            child: Text('${presupuesto.codigo} - ${presupuesto.nombre}'),
                                          );
                                        }),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedPresupuestoId = value;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Consumer<ConceptosProvider>(
                            builder: (context, conceptosProvider, child) {
                              return DropdownButtonFormField<int?>(
                                value: _selectedPadreId,
                                decoration: const InputDecoration(
                                  labelText: 'Concepto Padre',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    key: ValueKey('concepto-padre-null'),
                                    value: null,
                                    child: Text('Sin concepto padre'),
                                  ),
                                  ...conceptosProvider.conceptos
                                      .where((c) => c.id != widget.concepto?.id)
                                      .map((concepto) {
                                    return DropdownMenuItem<int?>(
                                      key: ValueKey('concepto-padre-${concepto.id}'),
                                      value: concepto.id,
                                      child: Text('${concepto.codigo} - ${concepto.nombre}'),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPadreId = value;
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Sección de Notas y Adjuntos
                    if (isEditing)
                      Column(
                        children: [
                          const SizedBox(height: 24),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConceptoComentariosScreen(
                                    concepto: widget.concepto!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.comment,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Notas y Adjuntos',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ver y agregar comentarios o archivos',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
