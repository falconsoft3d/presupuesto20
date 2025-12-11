import 'package:flutter/material.dart';

class RibbonBar extends StatelessWidget {
  final VoidCallback onNewObra;
  final String selectedView;
  final Function(String) onViewChanged;

  const RibbonBar({
    super.key,
    required this.onNewObra,
    required this.selectedView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Title Bar
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0078D4),
            ),
            child: Row(
              children: [
                const Icon(Icons.construction, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Presupuesto de Obras',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Ribbon Tabs
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                _buildTab('Inicio', 'inicio'),
                _buildTab('Datos', 'obras'),
              ],
            ),
          ),
          
          // Ribbon Content
          Container(
            height: 96,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Grupo: Nuevo
                _buildRibbonGroup(
                  'Nuevo',
                  [
                    _buildLargeButton(
                      icon: Icons.add_business,
                      label: 'Nueva Obra',
                      onPressed: onNewObra,
                    ),
                    const SizedBox(width: 4),
                    _buildLargeButton(
                      icon: Icons.note_add,
                      label: 'Presupuesto',
                      onPressed: () {},
                    ),
                  ],
                ),
                
                _buildDivider(),
                
                // Grupo: Acciones
                _buildRibbonGroup(
                  'Acciones',
                  [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _buildSmallButton(
                              icon: Icons.edit,
                              label: 'Editar',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            _buildSmallButton(
                              icon: Icons.delete,
                              label: 'Eliminar',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildSmallButton(
                              icon: Icons.copy,
                              label: 'Duplicar',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            _buildSmallButton(
                              icon: Icons.archive,
                              label: 'Archivar',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                _buildDivider(),
                
                // Grupo: Exportar
                _buildRibbonGroup(
                  'Exportar',
                  [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSmallButton(
                          icon: Icons.print,
                          label: 'Imprimir',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 4),
                        _buildSmallButton(
                          icon: Icons.picture_as_pdf,
                          label: 'PDF',
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSmallButton(
                          icon: Icons.table_chart,
                          label: 'Excel',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 4),
                        _buildSmallButton(
                          icon: Icons.email,
                          label: 'Email',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                
                _buildDivider(),
                
                // Grupo: Vista
                _buildRibbonGroup(
                  'Vista',
                  [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSmallButton(
                          icon: Icons.view_list,
                          label: 'Lista',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 4),
                        _buildSmallButton(
                          icon: Icons.grid_view,
                          label: 'Tarjetas',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = selectedView == value;
    return GestureDetector(
      onTap: () => onViewChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: isSelected ? const Color(0xFF0078D4) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? const Color(0xFF0078D4) : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRibbonGroup(String label, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF0078D4)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0078D4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade300,
    );
  }
}
