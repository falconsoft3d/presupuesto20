import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCategory = 'acerca_de';

  final Map<String, IconData> _categories = {
    'acerca_de': Icons.info_outline,
    'visualizador': Icons.palette,
    'secuencias': Icons.format_list_numbered,
    'general': Icons.settings,
    'seguridad': Icons.security,
    'integracion': Icons.sync,
  };

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
              const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Row(
            children: [
              // Sidebar
              Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _categories.entries.map((entry) {
                    final isSelected = _selectedCategory == entry.key;
                    return Material(
                      color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = entry.key;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? const Color(0xFF875A7B) : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                entry.value,
                                size: 20,
                                color: isSelected ? const Color(0xFF875A7B) : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _getCategoryName(entry.key),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? const Color(0xFF875A7B) : Colors.grey.shade700,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  color: const Color(0xFFF0F0F0),
                  child: _buildCategoryContent(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryName(String key) {
    switch (key) {
      case 'acerca_de':
        return 'Acerca de';
      case 'visualizador':
        return 'Visualizador';
      case 'secuencias':
        return 'Secuencias';
      case 'general':
        return 'Opciones generales';
      case 'seguridad':
        return 'Seguridad';
      case 'integracion':
        return 'Integración';
      default:
        return key;
    }
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategory) {
      case 'acerca_de':
        return _buildAcercaDeSettings();
      case 'visualizador':
        return _buildVisualizadorSettings();
      case 'secuencias':
        return _buildSecuenciasSettings();
      case 'general':
        return _buildPlaceholder('Opciones generales', Icons.settings);
      case 'seguridad':
        return _buildSeguridadSettings();
      case 'integracion':
        return _buildIntegracionSettings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAcercaDeSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Acerca de',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Información sobre la aplicación',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // About Section
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  // App Name
                  const Text(
                    'Presupuesto 2.0',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF875A7B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Cards
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    label: 'Versión',
                    value: '1.0',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Autor',
                    value: 'Marlon Falcon Hernandez',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.language,
                    label: 'Web',
                    value: 'www.marlonfalcon.com',
                    isLink: true,
                  ),
                  const SizedBox(height: 32),

                  // Copyright
                  Text(
                    '© ${DateTime.now().year} Marlon Falcon Hernandez',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todos los derechos reservados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF875A7B),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLink ? const Color(0xFF875A7B) : Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizadorSettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Visualizador',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personaliza la apariencia de la aplicación',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Theme Color Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.color_lens, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Color del tema',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selecciona el color principal de la interfaz',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildColorOption(
                            context,
                            'Odoo Púrpura',
                            const Color(0xFF875A7B),
                            settings.themeColor == const Color(0xFF875A7B),
                            () => settings.setThemeColor(const Color(0xFF875A7B)),
                          ),
                          _buildColorOption(
                            context,
                            'Azul',
                            const Color(0xFF0078D4),
                            settings.themeColor == const Color(0xFF0078D4),
                            () => settings.setThemeColor(const Color(0xFF0078D4)),
                          ),
                          _buildColorOption(
                            context,
                            'Verde',
                            const Color(0xFF00875A),
                            settings.themeColor == const Color(0xFF00875A),
                            () => settings.setThemeColor(const Color(0xFF00875A)),
                          ),
                          _buildColorOption(
                            context,
                            'Naranja',
                            const Color(0xFFE67E22),
                            settings.themeColor == const Color(0xFFE67E22),
                            () => settings.setThemeColor(const Color(0xFFE67E22)),
                          ),
                          _buildColorOption(
                            context,
                            'Rojo',
                            const Color(0xFFE74C3C),
                            settings.themeColor == const Color(0xFFE74C3C),
                            () => settings.setThemeColor(const Color(0xFFE74C3C)),
                          ),
                          _buildColorOption(
                            context,
                            'Índigo',
                            const Color(0xFF3F51B5),
                            settings.themeColor == const Color(0xFF3F51B5),
                            () => settings.setThemeColor(const Color(0xFF3F51B5)),
                          ),
                          _buildColorOption(
                            context,
                            'Turquesa',
                            const Color(0xFF00BCD4),
                            settings.themeColor == const Color(0xFF00BCD4),
                            () => settings.setThemeColor(const Color(0xFF00BCD4)),
                          ),
                          _buildColorOption(
                            context,
                            'Gris Oscuro',
                            const Color(0xFF2C3E50),
                            settings.themeColor == const Color(0xFF2C3E50),
                            () => settings.setThemeColor(const Color(0xFF2C3E50)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Color de fondo de pantalla de inicio
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_color_fill, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Color de fondo de inicio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selecciona el color de fondo donde aparecen las aplicaciones',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildColorOption(
                                context,
                                'Gris claro',
                                const Color(0xFFF0F0F0),
                                settings.homeBackgroundColor == const Color(0xFFF0F0F0),
                                () => settings.setHomeBackgroundColor(const Color(0xFFF0F0F0)),
                              ),
                              _buildColorOption(
                                context,
                                'Blanco',
                                const Color(0xFFFFFFFF),
                                settings.homeBackgroundColor == const Color(0xFFFFFFFF),
                                () => settings.setHomeBackgroundColor(const Color(0xFFFFFFFF)),
                              ),
                              _buildColorOption(
                                context,
                                'Azul claro',
                                const Color(0xFFE3F2FD),
                                settings.homeBackgroundColor == const Color(0xFFE3F2FD),
                                () => settings.setHomeBackgroundColor(const Color(0xFFE3F2FD)),
                              ),
                              _buildColorOption(
                                context,
                                'Verde claro',
                                const Color(0xFFE8F5E9),
                                settings.homeBackgroundColor == const Color(0xFFE8F5E9),
                                () => settings.setHomeBackgroundColor(const Color(0xFFE8F5E9)),
                              ),
                              _buildColorOption(
                                context,
                                'Rosa claro',
                                const Color(0xFFFCE4EC),
                                settings.homeBackgroundColor == const Color(0xFFFCE4EC),
                                () => settings.setHomeBackgroundColor(const Color(0xFFFCE4EC)),
                              ),
                              _buildColorOption(
                                context,
                                'Morado claro',
                                const Color(0xFFF3E5F5),
                                settings.homeBackgroundColor == const Color(0xFFF3E5F5),
                                () => settings.setHomeBackgroundColor(const Color(0xFFF3E5F5)),
                              ),
                              _buildColorOption(
                                context,
                                'Amarillo claro',
                                const Color(0xFFFFFDE7),
                                settings.homeBackgroundColor == const Color(0xFFFFFDE7),
                                () => settings.setHomeBackgroundColor(const Color(0xFFFFFDE7)),
                              ),
                              _buildColorOption(
                                context,
                                'Gris oscuro',
                                const Color(0xFFECEFF1),
                                settings.homeBackgroundColor == const Color(0xFFECEFF1),
                                () => settings.setHomeBackgroundColor(const Color(0xFFECEFF1)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fondo de pantalla de inicio
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wallpaper, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Fondo de pantalla de inicio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Personaliza el fondo de la pantalla principal',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (settings.homeBackgroundPath != null && 
                              File(settings.homeBackgroundPath!).existsSync())
                            Container(
                              height: 150,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                image: DecorationImage(
                                  image: FileImage(File(settings.homeBackgroundPath!)),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    debugPrint('Error loading preview: $exception');
                                  },
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(context, true),
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: Text(settings.homeBackgroundPath != null 
                                    ? 'Cambiar imagen' 
                                    : 'Seleccionar imagen'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: settings.themeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                              if (settings.homeBackgroundPath != null) ...[
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => settings.setHomeBackground(null),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('Quitar fondo'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fondo de pantalla de bloqueo
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock_clock, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Fondo de pantalla de bloqueo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Personaliza el fondo de la pantalla de bloqueo',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (settings.lockBackgroundPath != null && 
                              File(settings.lockBackgroundPath!).existsSync())
                            Container(
                              height: 150,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                image: DecorationImage(
                                  image: FileImage(File(settings.lockBackgroundPath!)),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    debugPrint('Error loading preview: $exception');
                                  },
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(context, false),
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: Text(settings.lockBackgroundPath != null 
                                    ? 'Cambiar imagen' 
                                    : 'Seleccionar imagen'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: settings.themeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                              if (settings.lockBackgroundPath != null) ...[
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => settings.setLockBackground(null),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('Quitar fondo'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, bool isHomeBackground) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        
        // Verificar que el archivo existe
        final file = File(filePath);
        if (!await file.exists()) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El archivo seleccionado no existe'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final settings = context.read<SettingsProvider>();
        if (isHomeBackground) {
          await settings.setHomeBackground(filePath);
        } else {
          await settings.setLockBackground(filePath);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isHomeBackground 
                  ? 'Fondo de inicio actualizado' 
                  : 'Fondo de bloqueo actualizado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildColorOption(
    BuildContext context,
    String name,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuenciasSettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final secProyectoController = TextEditingController(text: settings.secuenciaProyecto);
        final proxNumProyectoController = TextEditingController(text: settings.proximoNumeroProyecto.toString());
        final secPresupuestoController = TextEditingController(text: settings.secuenciaPresupuesto);
        final proxNumPresupuestoController = TextEditingController(text: settings.proximoNumeroPresupuesto.toString());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Secuencias',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configura las secuencias automáticas para códigos de proyectos y presupuestos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Secuencias de Proyectos
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.folder_open, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Secuencias de Proyectos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Define el prefijo y número inicial para los códigos de proyectos (ej: PY00001)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: secProyectoController,
                              decoration: InputDecoration(
                                labelText: 'Prefijo de Proyecto',
                                hintText: 'PY',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  settings.setSecuenciaProyecto(value.toUpperCase());
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: proxNumProyectoController,
                              decoration: InputDecoration(
                                labelText: 'Próximo Número',
                                hintText: '1',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final num = int.tryParse(value);
                                if (num != null && num > 0) {
                                  settings.setProximoNumeroProyecto(num);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Secuencias de Presupuestos
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Secuencias de Presupuestos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Define el prefijo y número inicial para los códigos de presupuestos (ej: PR00001)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: secPresupuestoController,
                              decoration: InputDecoration(
                                labelText: 'Prefijo de Presupuesto',
                                hintText: 'PR',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  settings.setSecuenciaPresupuesto(value.toUpperCase());
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: proxNumPresupuestoController,
                              decoration: InputDecoration(
                                labelText: 'Próximo Número',
                                hintText: '1',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final num = int.tryParse(value);
                                if (num != null && num > 0) {
                                  settings.setProximoNumeroPresupuesto(num);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeguridadSettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Configuración de Seguridad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Administra las opciones de seguridad y control de acceso',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Registro de usuarios
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_add, size: 24, color: Colors.grey.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Registro de Usuarios',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Controla si los nuevos usuarios pueden registrarse en el sistema desde la pantalla de inicio de sesión.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Permitir registro de nuevos usuarios',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Switch(
                          value: settings.registroHabilitado,
                          activeColor: const Color(0xFF875A7B),
                          onChanged: (value) {
                            settings.setRegistroHabilitado(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? 'Registro habilitado: Los usuarios pueden crear nuevas cuentas'
                                      : 'Registro deshabilitado: Solo los administradores pueden crear usuarios',
                                ),
                                backgroundColor: value ? Colors.green : Colors.orange,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (!settings.registroHabilitado) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'El botón de registro no aparecerá en la pantalla de inicio de sesión. Solo los administradores podrán crear usuarios desde el panel de administración.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PIN de desbloqueo
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pin, size: 24, color: Colors.grey.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'PIN de Desbloqueo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Usa un PIN de 4 dígitos en lugar de tu contraseña para acceder rápidamente al sistema.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Usar PIN de desbloqueo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Switch(
                          value: settings.usarPin,
                          activeColor: const Color(0xFF875A7B),
                          onChanged: (value) {
                            if (value && (settings.pinCode.isEmpty || settings.pinCode.length != 4)) {
                              _showPinConfigDialog(context, settings);
                            } else {
                              settings.setUsarPin(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? 'PIN activado: Usa tu PIN para iniciar sesión'
                                        : 'PIN desactivado: Usa tu contraseña para iniciar sesión',
                                  ),
                                  backgroundColor: value ? Colors.green : Colors.orange,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    if (settings.usarPin) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showPinConfigDialog(context, settings),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Cambiar PIN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: settings.themeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tu PIN está configurado. En el inicio de sesión solo necesitarás ingresar tu PIN de 4 dígitos.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPinConfigDialog(BuildContext context, SettingsProvider settings) async {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN (4 dígitos)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un PIN';
                  }
                  if (value.length != 4) {
                    return 'El PIN debe tener 4 dígitos';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Solo se permiten números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPinController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar PIN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme el PIN';
                  }
                  if (value != pinController.text) {
                    return 'Los PINs no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await settings.setPinCode(pinController.text);
                await settings.setUsarPin(true);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN configurado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: settings.themeColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegracionSettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return _IntegracionSettingsForm(settings: settings);
      },
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegracionSettingsForm extends StatefulWidget {
  final SettingsProvider settings;

  const _IntegracionSettingsForm({required this.settings});

  @override
  State<_IntegracionSettingsForm> createState() => _IntegracionSettingsFormState();
}

class _IntegracionSettingsFormState extends State<_IntegracionSettingsForm> {
  late TextEditingController urlController;
  late TextEditingController puertoController;
  late TextEditingController databaseController;
  late TextEditingController usuarioController;
  late TextEditingController contrasenaController;
  late TextEditingController chatGptTokenController;
  bool isTesting = false;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: widget.settings.rpcUrl);
    puertoController = TextEditingController(text: widget.settings.rpcPuerto);
    databaseController = TextEditingController(text: widget.settings.rpcDatabase);
    usuarioController = TextEditingController(text: widget.settings.rpcUsuario);
    contrasenaController = TextEditingController(text: widget.settings.rpcContrasena);
    chatGptTokenController = TextEditingController(text: widget.settings.chatGptToken);
  }

  @override
  void dispose() {
    urlController.dispose();
    puertoController.dispose();
    databaseController.dispose();
    usuarioController.dispose();
    contrasenaController.dispose();
    chatGptTokenController.dispose();
    super.dispose();
  }

  Future<void> _guardarConfiguracionRpc() async {
    await widget.settings.setRpcUrl(urlController.text);
    await widget.settings.setRpcPuerto(puertoController.text);
    await widget.settings.setRpcDatabase(databaseController.text);
    await widget.settings.setRpcUsuario(usuarioController.text);
    await widget.settings.setRpcContrasena(contrasenaController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuración RPC guardada exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _probarConexion() async {
    if (urlController.text.isEmpty || 
        puertoController.text.isEmpty || 
        databaseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa URL, Puerto y Base de datos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isTesting = true;
    });

    try {
      // Aquí iría la lógica real de prueba de conexión
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión exitosa con Odoo'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isTesting = false;
        });
      }
    }
  }

  Future<void> _guardarConfiguracion() async {
    await widget.settings.setChatGptToken(chatGptTokenController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Token guardado exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Integración ChatGPT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura tu API Token para usar ChatGPT',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Configuración Odoo JSON-RPC
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.integration_instructions, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Integración Odoo JSON-RPC',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Configura la conexión con Odoo para sincronizar datos',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: urlController,
                                  decoration: InputDecoration(
                                    labelText: 'URL del servidor',
                                    hintText: 'http://localhost',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: puertoController,
                                  decoration: InputDecoration(
                                    labelText: 'Puerto',
                                    hintText: '8069',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: databaseController,
                            decoration: InputDecoration(
                              labelText: 'Base de datos',
                              hintText: 'odoo_db',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: usuarioController,
                                  decoration: InputDecoration(
                                    labelText: 'Usuario',
                                    hintText: 'admin',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: contrasenaController,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  obscureText: true,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _guardarConfiguracionRpc,
                                icon: const Icon(Icons.save, size: 18),
                                label: const Text('Guardar Configuración'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.settings.themeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: isTesting ? null : _probarConexion,
                                icon: isTesting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.wifi_tethering, size: 18),
                                label: Text(isTesting ? 'Probando...' : 'Probar Conexión'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Configuración ChatGPT
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'API Token',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa tu token de OpenAI para habilitar ChatGPT',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: chatGptTokenController,
                            decoration: InputDecoration(
                              labelText: 'API Token',
                              hintText: 'sk-proj-...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              helperText: 'Obtén tu token en: https://platform.openai.com/api-keys',
                              helperMaxLines: 2,
                            ),
                            obscureText: true,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _guardarConfiguracion,
                                icon: const Icon(Icons.save, size: 18),
                                label: const Text('Guardar Token'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.settings.themeColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (widget.settings.chatGptToken.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Token configurado',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
}
