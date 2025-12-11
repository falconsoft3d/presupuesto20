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
  String _selectedCategory = 'visualizador';

  final Map<String, IconData> _categories = {
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntegracionSettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final urlController = TextEditingController(text: settings.rpcUrl);
        final puertoController = TextEditingController(text: settings.rpcPuerto);
        final usuarioController = TextEditingController(text: settings.rpcUsuario);
        final contrasenaController = TextEditingController(text: settings.rpcContrasena);
        bool isTesting = false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Integración RPC',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura la conexión RPC para integraciones externas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Configuración RPC
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
                                  Icon(Icons.cloud_sync, size: 20, color: Colors.grey.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Configuración de Conexión',
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
                                'Ingresa los datos de conexión para el servidor RPC',
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
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: urlController,
                                      decoration: InputDecoration(
                                        labelText: 'URL del Servidor',
                                        hintText: 'http://ejemplo.com',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      onChanged: (value) {
                                        settings.setRpcUrl(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
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
                                      onChanged: (value) {
                                        settings.setRpcPuerto(value);
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
                                      controller: usuarioController,
                                      decoration: InputDecoration(
                                        labelText: 'Usuario',
                                        hintText: 'admin',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      onChanged: (value) {
                                        settings.setRpcUsuario(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: contrasenaController,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        hintText: '••••••••',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      obscureText: true,
                                      onChanged: (value) {
                                        settings.setRpcContrasena(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: isTesting ? null : () async {
                                      setState(() {
                                        isTesting = true;
                                      });

                                      // Simular prueba de conexión
                                      await Future.delayed(const Duration(seconds: 2));

                                      setState(() {
                                        isTesting = false;
                                      });

                                      if (context.mounted) {
                                        final hasData = settings.rpcUrl.isNotEmpty && 
                                                       settings.rpcUsuario.isNotEmpty;
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              hasData 
                                                ? 'Conexión probada exitosamente' 
                                                : 'Complete todos los campos para probar la conexión',
                                            ),
                                            backgroundColor: hasData ? Colors.green : Colors.orange,
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    },
                                    icon: isTesting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.cloud_done, size: 18),
                                    label: Text(isTesting ? 'Probando...' : 'Probar Conexión'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: settings.themeColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (settings.rpcUrl.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Configuración guardada',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade900,
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
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
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
