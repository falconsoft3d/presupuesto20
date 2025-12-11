import 'package:flutter/material.dart';
import 'unidades_medida_screen.dart';
import 'monedas_screen.dart';
import 'categorias_productos_screen.dart';
import 'estados_screen.dart';

class DatosMaestrosScreen extends StatefulWidget {
  final VoidCallback onBack;

  const DatosMaestrosScreen({super.key, required this.onBack});

  @override
  State<DatosMaestrosScreen> createState() => _DatosMaestrosScreenState();
}

class _DatosMaestrosScreenState extends State<DatosMaestrosScreen> {
  String _selectedSubmenu = 'unidades';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar con tabs
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
              const Text(
                'Datos Maestros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 32),
              _buildTab('Unidades de Medida', 'unidades'),
              const SizedBox(width: 16),
              _buildTab('Monedas', 'monedas'),
              const SizedBox(width: 16),
              _buildTab('Categorías de Productos', 'categorias'),
              const SizedBox(width: 16),
              _buildTab('Estados', 'estados'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _buildSubmenuContent(),
        ),
      ],
    );
  }

  Widget _buildTab(String label, String submenuKey) {
    final isSelected = _selectedSubmenu == submenuKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSubmenu = submenuKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16A085).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A085) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF16A085) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenuContent() {
    switch (_selectedSubmenu) {
      case 'unidades':
        return const UnidadesMedidaScreen();
      case 'monedas':
        return const MonedasScreen();
      case 'categorias':
        return const CategoriasProductosScreen();
      case 'estados':
        return const EstadosScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  String _getSubmenuTitle() {
    switch (_selectedSubmenu) {
      case 'unidades':
        return 'Unidades de Medida';
      case 'monedas':
        return 'Monedas';
      case 'categorias':
        return 'Categorías de Productos';
      default:
        return '';
    }
  }
}
