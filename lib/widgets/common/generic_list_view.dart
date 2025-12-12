import 'package:flutter/material.dart';

/// Configuración de columna para la tabla genérica
class ColumnConfig {
  final String label;
  final double width;
  final String Function(dynamic item) getValue;
  final Widget Function(dynamic item)? customWidget;
  final bool sortable;

  ColumnConfig({
    required this.label,
    required this.width,
    required this.getValue,
    this.customWidget,
    this.sortable = true,
  });
}

/// Vista de lista genérica reutilizable estilo Odoo
class GenericListView<T> extends StatefulWidget {
  final List<T> items;
  final List<ColumnConfig> columns;
  final String title;
  final String emptyIcon;
  final String emptyMessage;
  final Function(T) onItemSelected;
  final Function(T)? onEdit;
  final Function(T)? onDelete;
  final VoidCallback onCreate;
  final List<String> Function(T)? getSearchableFields;
  final bool showImportButton;
  final List<Widget> Function(T)? customActions;

  const GenericListView({
    super.key,
    required this.items,
    required this.columns,
    required this.title,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.onItemSelected,
    this.onEdit,
    this.onDelete,
    required this.onCreate,
    this.getSearchableFields,
    this.showImportButton = false,
    this.customActions,
  });

  @override
  State<GenericListView<T>> createState() => _GenericListViewState<T>();
}

class _GenericListViewState<T> extends State<GenericListView<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _selectedIndices = {};


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_searchQuery.isEmpty || widget.getSearchableFields == null) {
      return widget.items;
    }
    
    return widget.items.where((item) {
      final searchFields = widget.getSearchableFields!(item);
      return searchFields.any((field) =>
        field.toLowerCase().contains(_searchQuery.toLowerCase())
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(widget.emptyIcon),
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza creando un nuevo registro',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onCreate,
              icon: const Icon(Icons.add),
              label: Text('Nuevo ${widget.title}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

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
              ElevatedButton(
                onPressed: widget.onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8),
                  elevation: 0,
                  minimumSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Icon(Icons.add, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                width: 250,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_list, size: 20),
                tooltip: 'Filtros',
                onPressed: () {},
              ),
            ],
          ),
        ),
        
        // Table Container
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Table Header
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Table(
                      columnWidths: {
                        0: const FixedColumnWidth(40),
                        for (int i = 0; i < widget.columns.length; i++)
                          i + 1: FixedColumnWidth(widget.columns[i].width),
                        widget.columns.length + 1: const FixedColumnWidth(80),
                      },
                      children: [
                        TableRow(
                          children: [
                            _buildHeaderCell(''),
                            for (var column in widget.columns)
                              _buildHeaderCell(column.label),
                            _buildHeaderCell(''),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Table Body
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron resultados',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 40 + widget.columns.fold<double>(0, (sum, col) => sum + col.width) + 80,
                            child: ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return _buildDataRow(filteredItems[index], index);
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(T item, int index) {
    return InkWell(
      onTap: () => widget.onItemSelected(item),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Table(
          columnWidths: {
            0: const FixedColumnWidth(40),
            for (int i = 0; i < widget.columns.length; i++)
              i + 1: FixedColumnWidth(widget.columns[i].width),
            widget.columns.length + 1: const FixedColumnWidth(80),
          },
          children: [
            TableRow(
              children: [
                _buildDataCell(
                  Checkbox(
                    value: _selectedIndices.contains(index),
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          _selectedIndices.add(index);
                        } else {
                          _selectedIndices.remove(index);
                        }
                      });
                    },
                  ),
                ),
                for (var column in widget.columns)
                  _buildDataCell(
                    column.customWidget != null
                        ? column.customWidget!(item)
                        : Text(
                            column.getValue(item),
                            style: const TextStyle(fontSize: 13),
                          ),
                  ),
                _buildDataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.customActions != null)
                        ...widget.customActions!(item).map((action) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: action,
                        )),
                      if (widget.onEdit != null) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => widget.onEdit!(item),
                          tooltip: 'Editar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => _confirmDelete(item),
                          tooltip: 'Eliminar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'contacts':
        return Icons.contacts_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  void _confirmDelete(T item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este elemento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete!(item);
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
