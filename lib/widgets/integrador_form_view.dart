import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/integradores_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/presupuestos_provider.dart';
import '../database/database.dart';
import '../services/integrador_service.dart';
import '../screens/conceptos_tree_screen.dart';

class IntegradorFormView extends StatefulWidget {
  final Integrador? integrador;
  final VoidCallback onBack;

  const IntegradorFormView({
    super.key,
    this.integrador,
    required this.onBack,
  });

  @override
  State<IntegradorFormView> createState() => _IntegradorFormViewState();
}

class _IntegradorFormViewState extends State<IntegradorFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _secuenciaController;
  String _selectedTipo = '2000';
  String? _rutaArchivo;
  String? _nombreArchivo;
  bool _isSaving = false;

  final List<String> _tiposIntegrador = ['2000', 'bc3'];

  @override
  void initState() {
    super.initState();
    
    if (widget.integrador != null) {
      _secuenciaController = TextEditingController(text: widget.integrador!.secuencia);
      _selectedTipo = widget.integrador!.tipo;
      _rutaArchivo = widget.integrador!.rutaArchivo;
      _nombreArchivo = widget.integrador!.nombreArchivo;
    } else {
      _secuenciaController = TextEditingController();
      // Generar secuencia automáticamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider = context.read<SettingsProvider>();
        _secuenciaController.text = _generarSecuencia(settingsProvider);
      });
    }
  }

  String _generarSecuencia(SettingsProvider settings) {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final contador = (settings.contadorIntegrador + 1).toString().padLeft(3, '0');
    return 'IMP-$year$month$contador';
  }

  @override
  void dispose() {
    _secuenciaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _rutaArchivo = result.files.single.path;
        _nombreArchivo = result.files.single.name;
      });
    }
  }

  Future<void> _procesarArchivo() async {
    if (_rutaArchivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debe seleccionar un archivo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final integradoresProvider = context.read<IntegradoresProvider>();
      final presupuestosProvider = context.read<PresupuestosProvider>();
      
      // Procesar el archivo según el tipo
      int? presupuestoId;
      String resultado = '';
      
      switch (_selectedTipo) {
        case '2000':
          final result = await _procesarArchivo2000Completo(_rutaArchivo!);
          presupuestoId = result['presupuestoId'];
          resultado = result['mensaje'];
          break;
        case 'bc3':
          resultado = await _procesarArchivoBc3(_rutaArchivo!);
          break;
      }

      await integradoresProvider.updateEstadoIntegrador(
        id: widget.integrador!.id,
        estado: 'Procesado',
        resultado: resultado,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo procesado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Si se creó un presupuesto, navegar a él
        if (presupuestoId != null) {
          await presupuestosProvider.loadPresupuestos();
          final presupuesto = presupuestosProvider.getPresupuestoById(presupuestoId);
          
          if (presupuesto != null && mounted) {
            widget.onBack();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ConceptosTreeScreen(
                  presupuesto: presupuesto,
                ),
              ),
            );
          } else {
            widget.onBack();
          }
        } else {
          widget.onBack();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        final integradoresProvider = context.read<IntegradoresProvider>();
        final errorMessage = e.toString();
        
        await integradoresProvider.updateEstadoIntegrador(
          id: widget.integrador!.id,
          estado: 'Error',
          resultado: errorMessage,
        );

        // Mostrar diálogo con el error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Error al procesar'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Se produjo un error al procesar el archivo:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: SelectableText(
                      errorMessage,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _procesarArchivo2000Completo(String ruta) async {
    final database = context.read<AppDatabase>();
    final service = IntegradorService(database);
    
    // Generar nombre del presupuesto
    final nombrePresupuesto = 'Presupuesto ${_secuenciaController.text}';
    
    // Procesar archivo
    final resultado = await service.procesarFormato2000(
      rutaArchivo: ruta,
      nombrePresupuesto: nombrePresupuesto,
    );
    
    if (resultado['success'] == true) {
      return {
        'presupuestoId': resultado['presupuestoId'],
        'mensaje': 'Presupuesto creado: ${resultado['presupuestoId']}\n'
                   'Capítulos: ${resultado['capitulos']}\n'
                   'Partidas: ${resultado['partidas']}\n'
                   'Recursos: ${resultado['recursos']}',
      };
    } else {
      throw Exception(resultado['message']);
    }
  }

  Future<String> _procesarArchivoBc3(String ruta) async {
    // TODO: Implementar procesamiento BC3
    await Future.delayed(const Duration(seconds: 2));
    
    final file = File(ruta);
    final tamano = await file.length();
    
    return 'Archivo BC3 procesado. Tamaño: ${(tamano / 1024).toStringAsFixed(2)} KB\n(Procesamiento BC3 pendiente de implementar)';
  }

  Future<void> _guardarYProcesar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rutaArchivo == null || _nombreArchivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un archivo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final integradoresProvider = context.read<IntegradoresProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final presupuestosProvider = context.read<PresupuestosProvider>();

    try {
      // Paso 1: Guardar el integrador
      if (widget.integrador != null) {
        await integradoresProvider.updateIntegrador(
          id: widget.integrador!.id,
          secuencia: _secuenciaController.text,
          tipo: _selectedTipo,
          nombreArchivo: _nombreArchivo!,
          rutaArchivo: _rutaArchivo!,
        );
      } else {
        await integradoresProvider.createIntegrador(
          secuencia: _secuenciaController.text,
          tipo: _selectedTipo,
          nombreArchivo: _nombreArchivo!,
          rutaArchivo: _rutaArchivo!,
        );
        
        // Incrementar contador
        await settingsProvider.incrementarContadorIntegrador();
      }

      // Paso 2: Procesar el archivo inmediatamente
      int? presupuestoId;
      String resultado = '';
      
      switch (_selectedTipo) {
        case '2000':
          final result = await _procesarArchivo2000Completo(_rutaArchivo!);
          presupuestoId = result['presupuestoId'];
          resultado = result['mensaje'];
          break;
        case 'bc3':
          resultado = await _procesarArchivoBc3(_rutaArchivo!);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guardado y procesado: $resultado'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Si se creó un presupuesto, navegar a él
        if (presupuestoId != null) {
          // Recargar presupuestos para obtener el nuevo
          await presupuestosProvider.loadPresupuestos();
          final presupuesto = presupuestosProvider.getPresupuestoById(presupuestoId);
          
          if (presupuesto != null && mounted) {
            // Primero volver atrás
            widget.onBack();
            // Luego navegar al presupuesto
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ConceptosTreeScreen(
                  presupuesto: presupuesto,
                ),
              ),
            );
          } else {
            widget.onBack();
          }
        } else {
          widget.onBack();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveIntegrador() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rutaArchivo == null || _nombreArchivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un archivo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final integradoresProvider = context.read<IntegradoresProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    try {
      if (widget.integrador != null) {
        await integradoresProvider.updateIntegrador(
          id: widget.integrador!.id,
          secuencia: _secuenciaController.text,
          tipo: _selectedTipo,
          nombreArchivo: _nombreArchivo!,
          rutaArchivo: _rutaArchivo!,
        );
      } else {
        await integradoresProvider.createIntegrador(
          secuencia: _secuenciaController.text,
          tipo: _selectedTipo,
          nombreArchivo: _nombreArchivo!,
          rutaArchivo: _rutaArchivo!,
        );
        
        // Incrementar contador
        await settingsProvider.incrementarContadorIntegrador();
      }

      if (mounted) {
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
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
    final isEditing = widget.integrador != null;
    final puedeProceser = isEditing && widget.integrador!.estado == 'Pendiente';

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
              Text(
                isEditing ? 'Editar Integrador' : 'Nuevo Integrador',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (puedeProceser) ...[
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _procesarArchivo,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Procesar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _guardarYProcesar,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload_file, size: 18),
                label: const Text('Guardar y Procesar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveIntegrador,
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
                          const Text(
                            'Información del Integrador',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _secuenciaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Secuencia *',
                                    border: OutlineInputBorder(),
                                    hintText: 'IMP-001',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'La secuencia es requerida';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedTipo,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo *',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _tiposIntegrador.map((tipo) {
                                    return DropdownMenuItem<String>(
                                      value: tipo,
                                      child: Text(tipo.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTipo = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Sección de archivo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Archivo a importar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_nombreArchivo != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.insert_drive_file,
                                          color: Colors.blue.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _nombreArchivo!,
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _nombreArchivo = null;
                                              _rutaArchivo = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                ElevatedButton.icon(
                                  onPressed: _seleccionarArchivo,
                                  icon: const Icon(Icons.upload_file, size: 18),
                                  label: Text(_nombreArchivo == null 
                                      ? 'Seleccionar archivo' 
                                      : 'Cambiar archivo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Estado y resultado si existe
                          if (isEditing) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estado',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.integrador!.estado == 'Procesado'
                                              ? Colors.green.withOpacity(0.1)
                                              : widget.integrador!.estado == 'Error'
                                                  ? Colors.red.withOpacity(0.1)
                                                  : Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          widget.integrador!.estado,
                                          style: TextStyle(
                                            color: widget.integrador!.estado == 'Procesado'
                                                ? Colors.green
                                                : widget.integrador!.estado == 'Error'
                                                    ? Colors.red
                                                    : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.integrador!.resultado != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Resultado del procesamiento',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  widget.integrador!.resultado!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ],
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
