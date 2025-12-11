import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conceptos_provider.dart';
import '../providers/productos_provider.dart';
import '../providers/presupuestos_provider.dart';
import '../providers/settings_provider.dart';
import '../database/database.dart';

class ConceptosScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ConceptosScreen({super.key, required this.onBack});

  @override
  State<ConceptosScreen> createState() => _ConceptosScreenState();
}

class _ConceptosScreenState extends State<ConceptosScreen> {
  Concepto? _selectedConcepto;
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return _selectedConcepto != null || _isCreating
        ? _buildFormView()
        : _buildListView();
  }

  Widget _buildListView() {
    return Consumer3<ConceptosProvider, ProductosProvider, PresupuestosProvider>(
      builder: (context, conceptosProvider, productosProvider, presupuestosProvider, child) {
        if (conceptosProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredConceptos = _searchQuery.isEmpty
            ? conceptosProvider.conceptos
            : conceptosProvider.conceptos.where((concepto) {
                final query = _searchQuery.toLowerCase();
                return concepto.codigo.toLowerCase().contains(query) ||
                    concepto.nombre.toLowerCase().contains(query);
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: widget.onBack,
                    tooltip: 'Volver',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar conceptos...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCreating = true;
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.watch<SettingsProvider>().themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                color: const Color(0xFFF0F0F0),
                child: filteredConceptos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay conceptos registrados'
                                  : 'No se encontraron conceptos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredConceptos.length,
                        itemBuilder: (context, index) {
                          final concepto = filteredConceptos[index];
                          
                          // Obtener nombre del producto
                          String productoNombre = '-';
                          if (concepto.productoId != null) {
                            final producto = productosProvider.getProductoById(concepto.productoId!);
                            if (producto != null) {
                              productoNombre = producto.nombre;
                            }
                          }
                          
                          // Obtener nombre del presupuesto
                          String presupuestoNombre = '-';
                          if (concepto.presupuestoId != null) {
                            final presupuesto = presupuestosProvider.getPresupuestoById(concepto.presupuestoId!);
                            if (presupuesto != null) {
                              presupuestoNombre = presupuesto.nombre;
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: context.watch<SettingsProvider>().themeColor,
                                child: const Icon(Icons.category, color: Colors.white, size: 20),
                              ),
                              title: Text(
                                concepto.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Código: ${concepto.codigo}'),
                                  Text('Tipo: ${concepto.tipoRecurso}'),
                                  if (concepto.productoId != null)
                                    Text('Producto: $productoNombre'),
                                  if (concepto.presupuestoId != null)
                                    Text('Presupuesto: $presupuestoNombre'),
                                  Text('Cantidad: ${concepto.cantidad} | Coste: \$${concepto.coste.toStringAsFixed(2)} | Importe: \$${concepto.importe.toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedConcepto = concepto;
                                      });
                                    },
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () => _showDeleteDialog(concepto),
                                    tooltip: 'Eliminar',
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedConcepto = concepto;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(Concepto concepto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Concepto'),
        content: Text('¿Está seguro de eliminar el concepto "${concepto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ConceptosProvider>().deleteConcepto(concepto.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Concepto eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildFormView() {
    final provider = context.read<ConceptosProvider>();
    final productosProvider = context.watch<ProductosProvider>();
    final presupuestosProvider = context.watch<PresupuestosProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final isEditing = _selectedConcepto != null;
    
    final codigoController = TextEditingController(
      text: isEditing ? _selectedConcepto!.codigo : '',
    );
    final nombreController = TextEditingController(
      text: isEditing ? _selectedConcepto!.nombre : '',
    );
    final cantidadController = TextEditingController(
      text: isEditing ? _selectedConcepto!.cantidad.toString() : '0',
    );
    final costeController = TextEditingController(
      text: isEditing ? _selectedConcepto!.coste.toString() : '0',
    );
    final importeController = TextEditingController(
      text: isEditing ? _selectedConcepto!.importe.toString() : '0',
    );
    
    int? selectedProductoId = isEditing ? _selectedConcepto!.productoId : null;
    int? selectedPadreId = isEditing ? _selectedConcepto!.padreId : null;
    int? selectedPresupuestoId = isEditing ? _selectedConcepto!.presupuestoId : null;
    String selectedTipoRecurso = isEditing ? _selectedConcepto!.tipoRecurso : 'Material';
    
    final formKey = GlobalKey<FormState>();
    
    final tiposRecurso = ['Material', 'Servicio', 'Mano de obra', 'Equipo', 'Otros'];

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
                    _selectedConcepto = null;
                    _isCreating = false;
                  });
                },
                tooltip: 'Volver',
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? 'Editar Concepto' : 'Nuevo Concepto',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                key: formKey,
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
                                  controller: codigoController,
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
                                  controller: nombreController,
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
                                  controller: cantidadController,
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
                                  controller: costeController,
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
                                  controller: importeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Importe',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
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
                          DropdownButtonFormField<String>(
                            value: selectedTipoRecurso,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Recurso *',
                              border: OutlineInputBorder(),
                            ),
                            items: tiposRecurso.map((tipo) {
                              return DropdownMenuItem<String>(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedTipoRecurso = value!;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int?>(
                                  value: selectedProductoId,
                                  decoration: const InputDecoration(
                                    labelText: 'Producto',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Seleccionar producto...'),
                                    ),
                                    ...productosProvider.productos.map((producto) {
                                      return DropdownMenuItem<int?>(
                                        value: producto.id,
                                        child: Text(producto.nombre),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    selectedProductoId = value;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<int?>(
                                  value: selectedPresupuestoId,
                                  decoration: const InputDecoration(
                                    labelText: 'Presupuesto',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Seleccionar presupuesto...'),
                                    ),
                                    ...presupuestosProvider.presupuestos.map((presupuesto) {
                                      return DropdownMenuItem<int?>(
                                        value: presupuesto.id,
                                        child: Text(presupuesto.nombre),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    selectedPresupuestoId = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            value: selectedPadreId,
                            decoration: const InputDecoration(
                              labelText: 'Concepto Padre',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Sin concepto padre...'),
                              ),
                              ...provider.conceptos
                                  .where((c) => c.id != _selectedConcepto?.id)
                                  .map((concepto) {
                                return DropdownMenuItem<int?>(
                                  value: concepto.id,
                                  child: Text(concepto.nombre),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              selectedPadreId = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              if (isEditing) {
                                await provider.updateConcepto(
                                  id: _selectedConcepto!.id,
                                  codigo: codigoController.text,
                                  nombre: nombreController.text,
                                  cantidad: double.tryParse(cantidadController.text) ?? 0.0,
                                  coste: double.tryParse(costeController.text) ?? 0.0,
                                  importe: double.tryParse(importeController.text) ?? 0.0,
                                  productoId: selectedProductoId,
                                  padreId: selectedPadreId,
                                  presupuestoId: selectedPresupuestoId,
                                  tipoRecurso: selectedTipoRecurso,
                                );
                              } else {
                                await provider.createConcepto(
                                  codigo: codigoController.text,
                                  nombre: nombreController.text,
                                  cantidad: double.tryParse(cantidadController.text) ?? 0.0,
                                  coste: double.tryParse(costeController.text) ?? 0.0,
                                  importe: double.tryParse(importeController.text) ?? 0.0,
                                  productoId: selectedProductoId,
                                  padreId: selectedPadreId,
                                  presupuestoId: selectedPresupuestoId,
                                  tipoRecurso: selectedTipoRecurso,
                                );
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEditing
                                        ? 'Concepto actualizado correctamente'
                                        : 'Concepto creado correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                setState(() {
                                  _selectedConcepto = null;
                                  _isCreating = false;
                                });
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
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settingsProvider.themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
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
  }
}
