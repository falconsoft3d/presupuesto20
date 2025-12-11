import 'package:flutter/material.dart';

/// Configuración de campo para el formulario genérico
class FieldConfig {
  final String key;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final String? helperText;
  final Widget? suffix;
  final bool isRequired;
  final List<String>? dropdownItems;
  final bool isDropdown;

  FieldConfig({
    required this.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.helperText,
    this.suffix,
    this.isRequired = false,
    this.dropdownItems,
    this.isDropdown = false,
  });
}

/// Configuración de sección para agrupar campos
class SectionConfig {
  final String title;
  final List<FieldConfig> fields;
  final int columns;

  SectionConfig({
    required this.title,
    required this.fields,
    this.columns = 2,
  });
}

/// Vista de formulario genérica reutilizable estilo Odoo
class GenericFormView extends StatefulWidget {
  final String title;
  final bool isEditing;
  final List<SectionConfig> sections;
  final VoidCallback onBack;
  final Future<void> Function() onSave;
  final VoidCallback? onArchive;
  final VoidCallback? onDuplicate;
  final Widget? headerWidget;
  final GlobalKey<FormState> formKey;

  const GenericFormView({
    super.key,
    required this.title,
    required this.isEditing,
    required this.sections,
    required this.onBack,
    required this.onSave,
    required this.formKey,
    this.onArchive,
    this.onDuplicate,
    this.headerWidget,
  });

  @override
  State<GenericFormView> createState() => _GenericFormViewState();
}

class _GenericFormViewState extends State<GenericFormView> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
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
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF875A7B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Descartar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const Spacer(),
              if (widget.isEditing) ...[
                if (widget.onArchive != null)
                  IconButton(
                    icon: const Icon(Icons.archive_outlined, size: 20),
                    onPressed: widget.onArchive,
                    tooltip: 'Archivar',
                  ),
                if (widget.onDuplicate != null)
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 20),
                    onPressed: widget.onDuplicate,
                    tooltip: 'Duplicar',
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete();
                    }
                  },
                ),
              ],
            ],
          ),
        ),

        // Form content
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.grey.shade50,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header widget (opcional)
                        if (widget.headerWidget != null) ...[
                          widget.headerWidget!,
                          const SizedBox(height: 24),
                        ],

                        // Sections
                        for (var section in widget.sections) ...[
                          _buildSection(section),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(SectionConfig section) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: section.columns == 1
                ? Column(
                    children: section.fields
                        .map((field) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildField(field),
                            ))
                        .toList(),
                  )
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: section.fields
                        .map((field) => SizedBox(
                              width: (MediaQuery.of(context).size.width - 112) / section.columns,
                              child: _buildField(field),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FieldConfig field) {
    if (field.isDropdown && field.dropdownItems != null) {
      return DropdownButtonFormField<String>(
        value: field.controller.text.isEmpty ? null : field.controller.text,
        decoration: InputDecoration(
          labelText: field.label + (field.isRequired ? ' *' : ''),
          helperText: field.helperText,
          border: const OutlineInputBorder(),
          enabled: field.enabled,
        ),
        items: field.dropdownItems!
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: field.enabled
            ? (value) {
                if (value != null) {
                  field.controller.text = value;
                }
              }
            : null,
        validator: field.validator ??
            (field.isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }
                : null),
      );
    }

    return TextFormField(
      controller: field.controller,
      decoration: InputDecoration(
        labelText: field.label + (field.isRequired ? ' *' : ''),
        helperText: field.helperText,
        suffix: field.suffix,
        border: const OutlineInputBorder(),
        enabled: field.enabled,
      ),
      keyboardType: field.keyboardType,
      maxLines: field.maxLines,
      validator: field.validator ??
          (field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                }
              : null),
    );
  }

  Future<void> _handleSave() async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.title} guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este ${widget.title.toLowerCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
