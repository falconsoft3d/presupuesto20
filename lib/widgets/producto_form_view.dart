import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/productos_provider.dart';
import '../database/database.dart';
import '../widgets/common/generic_form_view.dart';

class ProductoFormView extends StatefulWidget {
  final Producto? producto;
  final VoidCallback onBack;

  const ProductoFormView({
    super.key,
    this.producto,
    required this.onBack,
  });

  @override
  State<ProductoFormView> createState() => _ProductoFormViewState();
}

class _ProductoFormViewState extends State<ProductoFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _precioController;
  late TextEditingController _costeController;
  late TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.producto?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.producto?.nombre ?? '');
    _tipoController = TextEditingController(text: widget.producto?.tipo ?? 'Material');
    _precioController = TextEditingController(
      text: widget.producto?.precio.toStringAsFixed(2) ?? '0.00',
    );
    _costeController = TextEditingController(
      text: widget.producto?.coste.toStringAsFixed(2) ?? '0.00',
    );
    _descripcionController = TextEditingController(text: widget.producto?.descripcion ?? '');
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _tipoController.dispose();
    _precioController.dispose();
    _costeController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.producto != null;

    return GenericFormView(
      title: 'Producto',
      isEditing: isEditing,
      formKey: _formKey,
      onBack: widget.onBack,
      onSave: _saveProducto,
      sections: [
        SectionConfig(
          title: 'Información del Producto',
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
              key: 'tipo',
              label: 'Tipo de Recurso',
              controller: _tipoController,
              isRequired: true,
              isDropdown: true,
              dropdownItems: const [
                'Material',
                'Mano de Obra',
                'Equipo',
                'Subcontrato',
                'Administrativo',
                'Otro',
              ],
            ),
          ],
        ),
        SectionConfig(
          title: 'Precios',
          columns: 2,
          fields: [
            FieldConfig(
              key: 'precio',
              label: 'Precio',
              controller: _precioController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              isRequired: true,
              suffix: Text('\$', style: TextStyle(color: Colors.grey.shade600)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio es requerido';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
            FieldConfig(
              key: 'coste',
              label: 'Coste',
              controller: _costeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              isRequired: true,
              suffix: Text('\$', style: TextStyle(color: Colors.grey.shade600)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El coste es requerido';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
          ],
        ),
        SectionConfig(
          title: 'Descripción',
          columns: 1,
          fields: [
            FieldConfig(
              key: 'descripcion',
              label: 'Descripción',
              controller: _descripcionController,
              maxLines: 5,
            ),
          ],
        ),
      ],
      headerWidget: _buildHeader(),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2,
              size: 40,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nombreController.text.isEmpty
                      ? 'Nuevo Producto'
                      : _nombreController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _codigoController.text.isEmpty
                          ? 'Sin código'
                          : _codigoController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        _tipoController.text.isEmpty
                            ? 'Material'
                            : _tipoController.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'Precio: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${_precioController.text}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Coste: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '\$${_costeController.text}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveProducto() async {
    final provider = Provider.of<ProductosProvider>(context, listen: false);

    if (widget.producto == null) {
      // Crear nuevo producto
      await provider.createProducto(
        codigo: _codigoController.text,
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        precio: double.parse(_precioController.text),
        coste: double.parse(_costeController.text),
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      );
    } else {
      // Actualizar producto existente
      final updatedProducto = widget.producto!.copyWith(
        codigo: _codigoController.text,
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        precio: double.parse(_precioController.text),
        coste: double.parse(_costeController.text),
        descripcion: drift.Value(_descripcionController.text.isEmpty ? null : _descripcionController.text),
      );
      await provider.updateProducto(updatedProducto);
    }
  }
}
