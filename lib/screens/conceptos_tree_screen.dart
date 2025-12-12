import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../providers/monedas_provider.dart';
import '../providers/conceptos_provider.dart';
import '../widgets/concepto_form_view.dart';

class ConceptosTreeScreen extends StatefulWidget {
  final Presupuesto presupuesto;

  const ConceptosTreeScreen({
    super.key,
    required this.presupuesto,
  });

  @override
  State<ConceptosTreeScreen> createState() => _ConceptosTreeScreenState();
}

class _ConceptosTreeScreenState extends State<ConceptosTreeScreen> {
  List<Concepto> _conceptos = [];
  Concepto? _selectedConcepto;
  bool _isLoading = true;
  final Set<int> _expandedNodes = {};
  Concepto? _copiedConcepto;
  Concepto? _conceptoParaMover;
  bool _forceShowForm = false;
  
  // Para edición inline
  int? _editingConceptoId;
  String _editingField = '';
  final Map<int, TextEditingController> _codigoControllers = {};
  final Map<int, TextEditingController> _nombreControllers = {};
  final Map<int, TextEditingController> _cantidadControllers = {};
  final Map<int, TextEditingController> _costeControllers = {};
  
  // Para el divisor arrastrable
  double _leftPanelWidth = 400;

  @override
  void initState() {
    super.initState();
    _loadConceptos();
  }

  Future<void> _loadConceptos() async {
    setState(() => _isLoading = true);
    try {
      final database = context.read<AppDatabase>();
      final conceptos = await database.getConceptosByPresupuesto(widget.presupuesto.id);
      setState(() {
        _conceptos = conceptos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando conceptos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recalcularTotales() async {
    setState(() => _isLoading = true);
    try {
      final conceptosProvider = context.read<ConceptosProvider>();
      await conceptosProvider.recalcularTotales(widget.presupuesto.id);
      await _loadConceptos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Totales recalculados correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error recalculando totales: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al recalcular: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Concepto> _getChildrenConceptos(int? padreId) {
    return _conceptos.where((c) => c.padreId == padreId).toList();
  }

  bool _hasChildren(int conceptoId) {
    return _conceptos.any((c) => c.padreId == conceptoId);
  }

  String _getMonedaSigno() {
    if (widget.presupuesto.monedaId == null) return '\$';
    try {
      final monedasProvider = context.read<MonedasProvider>();
      final moneda = monedasProvider.getMonedaById(widget.presupuesto.monedaId!);
      return moneda?.signo ?? '\$';
    } catch (e) {
      return '\$';
    }
  }

  void _toggleExpanded(int conceptoId) {
    setState(() {
      if (_expandedNodes.contains(conceptoId)) {
        _expandedNodes.remove(conceptoId);
      } else {
        _expandedNodes.add(conceptoId);
      }
    });
  }

  IconData _getIconForTipoRecurso(String tipoRecurso) {
    switch (tipoRecurso.toLowerCase()) {
      case 'capítulo':
        return Icons.inbox; // Caja verde
      case 'partida':
        return Icons.dashboard; // Caja naranja
      case 'mano de obra':
        return Icons.person; // Persona verde
      case 'material':
        return Icons.inventory; // Material naranja
      case 'equipo':
        return Icons.settings; // Rueda roja
      case 'otros':
        return Icons.percent; // % negro
      default:
        return Icons.circle;
    }
  }

  Color _getColorForTipoRecurso(String tipoRecurso) {
    switch (tipoRecurso.toLowerCase()) {
      case 'capítulo':
        return Colors.green.shade700; // Verde
      case 'partida':
        return Colors.orange.shade700; // Naranja
      case 'mano de obra':
        return Colors.green.shade700; // Verde
      case 'material':
        return Colors.orange.shade700; // Naranja
      case 'equipo':
        return Colors.red.shade700; // Rojo
      case 'otros':
        return Colors.black87; // Negro
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildTreeNode(Concepto concepto, int level) {
    final hasChildren = _hasChildren(concepto.id);
    final isExpanded = _expandedNodes.contains(concepto.id);
    final isSelected = _selectedConcepto?.id == concepto.id;
    final children = hasChildren ? _getChildrenConceptos(concepto.id) : <Concepto>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onSecondaryTapDown: (details) {
            _showContextMenu(context, details.globalPosition, concepto);
          },
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedConcepto = concepto;
                _forceShowForm = false;
                if (hasChildren) {
                  _toggleExpanded(concepto.id);
                }
              });
            },
            onDoubleTap: () {
              setState(() => _selectedConcepto = concepto);
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 16.0 + (level * 24.0),
                right: 8,
                top: 6,
                bottom: 6,
              ),
              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
              child: Row(
                children: [
                  if (hasChildren)
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade600,
                    )
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 4),
                  Icon(
                    _getIconForTipoRecurso(concepto.tipoRecurso),
                    size: 18,
                    color: _getColorForTipoRecurso(concepto.tipoRecurso),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '[${concepto.codigo}] ${concepto.nombre}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded && hasChildren)
          ...children.map((child) => _buildTreeNode(child, level + 1)),
      ],
    );
  }

  void _showContextMenu(BuildContext context, Offset position, Concepto concepto) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.open_in_new, size: 18),
              SizedBox(width: 12),
              Text('Abrir'),
            ],
          ),
          onTap: () {
            setState(() {
              _selectedConcepto = concepto;
              _forceShowForm = true;
            });
          },
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 12),
              Text('Nuevo Concepto Hijo'),
            ],
          ),
          onTap: () => _nuevoConceptoHijo(concepto),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.content_copy, size: 18),
              SizedBox(width: 12),
              Text('Copiar Concepto'),
            ],
          ),
          onTap: () => _copiarConcepto(concepto),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          enabled: _copiedConcepto != null,
          child: Row(
            children: [
              Icon(
                Icons.content_paste,
                size: 18,
                color: _copiedConcepto != null ? null : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                'Pegar Concepto',
                style: TextStyle(
                  color: _copiedConcepto != null ? null : Colors.grey,
                ),
              ),
            ],
          ),
          onTap: () => _pegarConcepto(concepto),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.drive_file_move, size: 18),
              SizedBox(width: 12),
              Text('Cortar para Mover'),
            ],
          ),
          onTap: () => _cortarConcepto(concepto),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          enabled: _conceptoParaMover != null && _conceptoParaMover!.id != concepto.id,
          child: Row(
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                size: 18,
                color: _conceptoParaMover != null && _conceptoParaMover!.id != concepto.id ? null : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text(
                'Mover Aquí',
                style: TextStyle(
                  color: _conceptoParaMover != null && _conceptoParaMover!.id != concepto.id ? null : Colors.grey,
                ),
              ),
            ],
          ),
          onTap: () => _moverConceptoAqui(concepto),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Eliminar Concepto', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _eliminarConcepto(concepto),
        ),
      ],
    );
  }

  void _showContextMenuForPresupuesto(BuildContext context, Offset position) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final items = <PopupMenuEntry<String>>[];
    
    if (_copiedConcepto != null) {
      items.add(
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.content_paste, size: 18),
              SizedBox(width: 12),
              Text('Pegar Concepto'),
            ],
          ),
          onTap: () => _pegarConceptoEnPresupuesto(),
        ),
      );
    }
    
    if (_conceptoParaMover != null) {
      if (items.isNotEmpty) {
        items.add(const PopupMenuDivider());
      }
      items.add(
        PopupMenuItem<String>(
          child: const Row(
            children: [
              Icon(Icons.drive_file_move, size: 18),
              SizedBox(width: 12),
              Text('Mover a Raíz'),
            ],
          ),
          onTap: () => _moverConceptoARaiz(),
        ),
      );
    }
    
    if (items.isEmpty) return;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: items,
    );
  }

  Future<void> _pegarConceptoEnPresupuesto() async {
    if (_copiedConcepto == null) return;

    try {
      final database = context.read<AppDatabase>();
      
      // Copiar el concepto y toda su jerarquía en el nivel raíz
      await _copiarConceptoConHijos(_copiedConcepto!, null, database);

      await _loadConceptos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Concepto y descendientes pegados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al pegar concepto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generarCodigoAutomatico(int? padreId) {
    if (padreId == null) {
      // Generar código para capítulo raíz (01, 02, 03, etc.)
      final hijosRaiz = _conceptos.where((c) => c.padreId == null).toList();
      final siguienteNumero = hijosRaiz.length + 1;
      return siguienteNumero.toString().padLeft(2, '0');
    } else {
      // Generar código para hijo (padre.1, padre.2, etc.)
      final padre = _conceptos.firstWhere((c) => c.id == padreId);
      final hermanos = _conceptos.where((c) => c.padreId == padreId).toList();
      final siguienteNumero = hermanos.length + 1;
      return '${padre.codigo}.${siguienteNumero}';
    }
  }

  Future<void> _nuevoConceptoRaiz() async {
    final codigoSugerido = _generarCodigoAutomatico(null);
    await _mostrarDialogoNuevoConcepto(null, codigoSugerido);
  }

  Future<void> _nuevoConceptoHijo(Concepto padre) async {
    final codigoSugerido = _generarCodigoAutomatico(padre.id);
    await _mostrarDialogoNuevoConcepto(padre, codigoSugerido);
  }

  Future<void> _mostrarDialogoNuevoConcepto(Concepto? padre, String codigoSugerido) async {
    final codigoController = TextEditingController(text: codigoSugerido);
    final nombreController = TextEditingController();
    String tipoRecurso = padre == null ? 'Capítulo' : 'Partida';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(padre == null ? 'Nuevo Capítulo' : 'Nuevo Concepto Hijo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tipoRecurso,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Recurso',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Capítulo', child: Text('Capítulo')),
                  DropdownMenuItem(value: 'Partida', child: Text('Partida')),
                  DropdownMenuItem(value: 'Material', child: Text('Material')),
                  DropdownMenuItem(value: 'Mano de obra', child: Text('Mano de obra')),
                  DropdownMenuItem(value: 'Equipo', child: Text('Equipo')),
                  DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                ],
                onChanged: (value) {
                  if (value != null) tipoRecurso = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (confirmed == true && codigoController.text.isNotEmpty && nombreController.text.isNotEmpty) {
      try {
        final database = context.read<AppDatabase>();
        await database.insertConcepto(
          ConceptosCompanion.insert(
            codigo: codigoController.text,
            nombre: nombreController.text,
            tipoRecurso: tipoRecurso,
            cantidad: const drift.Value(0),
            coste: const drift.Value(0),
            presupuestoId: drift.Value(widget.presupuesto.id),
            padreId: drift.Value(padre?.id),
          ),
        );

        await _loadConceptos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Concepto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear concepto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    codigoController.dispose();
    nombreController.dispose();
  }

  void _copiarConcepto(Concepto concepto) {
    setState(() {
      _copiedConcepto = concepto;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Concepto "${concepto.nombre}" copiado'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cortarConcepto(Concepto concepto) {
    setState(() {
      _conceptoParaMover = concepto;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Concepto "${concepto.nombre}" listo para mover'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _moverConceptoAqui(Concepto nuevoPadre) async {
    if (_conceptoParaMover == null) return;

    // Verificar que no se esté intentando mover un concepto a sí mismo
    if (_conceptoParaMover!.id == nuevoPadre.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes mover un concepto a sí mismo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar que no se esté intentando mover un concepto a uno de sus descendientes
    if (_esDescendiente(nuevoPadre.id, _conceptoParaMover!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes mover un concepto a uno de sus descendientes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final database = context.read<AppDatabase>();
      
      // Actualizar el padre del concepto
      await database.updateConcepto(
        _conceptoParaMover!.copyWith(
          padreId: drift.Value(nuevoPadre.id),
        ),
      );

      setState(() {
        _conceptoParaMover = null;
      });

      await _loadConceptos();
      
      if (mounted) {
        final countHijos = _contarDescendientes(_conceptoParaMover!.id);
        final mensaje = countHijos > 0
            ? 'Concepto y $countHijos descendiente${countHijos != 1 ? 's' : ''} movido${countHijos != 1 ? 's' : ''} exitosamente'
            : 'Concepto movido exitosamente';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mover concepto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _moverConceptoARaiz() async {
    if (_conceptoParaMover == null) return;

    try {
      final database = context.read<AppDatabase>();
      
      // Actualizar el concepto para que sea raíz (sin padre)
      await database.updateConcepto(
        _conceptoParaMover!.copyWith(
          padreId: const drift.Value(null),
        ),
      );

      setState(() {
        _conceptoParaMover = null;
      });

      await _loadConceptos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Concepto movido a raíz exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al mover concepto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _esDescendiente(int posibleDescendienteId, int ancestroId) {
    final concepto = _conceptos.firstWhere((c) => c.id == posibleDescendienteId);
    if (concepto.padreId == null) return false;
    if (concepto.padreId == ancestroId) return true;
    return _esDescendiente(concepto.padreId!, ancestroId);
  }

  int _contarDescendientes(int conceptoId) {
    final hijos = _conceptos.where((c) => c.padreId == conceptoId).toList();
    int total = hijos.length;
    for (final hijo in hijos) {
      total += _contarDescendientes(hijo.id);
    }
    return total;
  }

  TextEditingController _getOrCreateControllerNumber(int conceptoId, String field, double value) {
    final map = field == 'cantidad' ? _cantidadControllers : _costeControllers;
    if (!map.containsKey(conceptoId)) {
      map[conceptoId] = TextEditingController(text: value.toStringAsFixed(2));
    }
    return map[conceptoId]!;
  }

  TextEditingController _getOrCreateControllerText(int conceptoId, String field, String value) {
    final map = field == 'codigo' ? _codigoControllers : _nombreControllers;
    if (!map.containsKey(conceptoId)) {
      map[conceptoId] = TextEditingController(text: value);
    }
    return map[conceptoId]!;
  }

  Future<void> _saveInlineEdit(Concepto concepto, String field) async {
    if (_editingConceptoId != concepto.id) return;

    try {
      final database = context.read<AppDatabase>();
      
      String newCodigo = concepto.codigo;
      String newNombre = concepto.nombre;
      double newCantidad = concepto.cantidad;
      double newCoste = concepto.coste;
      
      if (field == 'codigo') {
        newCodigo = _codigoControllers[concepto.id]!.text;
      } else if (field == 'nombre') {
        newNombre = _nombreControllers[concepto.id]!.text;
      } else if (field == 'cantidad') {
        newCantidad = double.tryParse(_cantidadControllers[concepto.id]!.text) ?? concepto.cantidad;
      } else if (field == 'coste') {
        newCoste = double.tryParse(_costeControllers[concepto.id]!.text) ?? concepto.coste;
      }
      
      // Calcular el importe (cantidad * coste)
      final newImporte = newCantidad * newCoste;
      
      // Crear un concepto actualizado con el nuevo valor
      final updatedConcepto = Concepto(
        id: concepto.id,
        codigo: newCodigo,
        nombre: newNombre,
        cantidad: newCantidad,
        coste: newCoste,
        importe: newImporte,
        productoId: concepto.productoId,
        padreId: concepto.padreId,
        presupuestoId: concepto.presupuestoId,
        tipoRecurso: concepto.tipoRecurso,
        fechaCreacion: concepto.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );
      
      await database.updateConcepto(updatedConcepto);

      setState(() {
        _editingConceptoId = null;
        _editingField = '';
      });

      await _loadConceptos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _codigoControllers.values) {
      controller.dispose();
    }
    for (var controller in _nombreControllers.values) {
      controller.dispose();
    }
    for (var controller in _cantidadControllers.values) {
      controller.dispose();
    }
    for (var controller in _costeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pegarConcepto(Concepto padre) async {
    if (_copiedConcepto == null) return;

    try {
      final database = context.read<AppDatabase>();
      
      // Copiar el concepto y toda su jerarquía
      await _copiarConceptoConHijos(_copiedConcepto!, padre.id, database);

      await _loadConceptos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Concepto y descendientes pegados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al pegar concepto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int> _copiarConceptoConHijos(Concepto concepto, int? nuevoPadreId, AppDatabase database) async {
    // Crear una copia del concepto actual
    final nuevoId = await database.insertConcepto(
      ConceptosCompanion.insert(
        codigo: concepto.codigo,
        nombre: nuevoPadreId == concepto.padreId ? concepto.nombre : '${concepto.nombre} (Copia)',
        tipoRecurso: concepto.tipoRecurso,
        cantidad: drift.Value(concepto.cantidad),
        coste: drift.Value(concepto.coste),
        presupuestoId: drift.Value(widget.presupuesto.id),
        padreId: drift.Value(nuevoPadreId),
      ),
    );

    // Copiar recursivamente todos los hijos
    final hijos = _conceptos.where((c) => c.padreId == concepto.id).toList();
    for (final hijo in hijos) {
      await _copiarConceptoConHijos(hijo, nuevoId, database);
    }

    return nuevoId;
  }

  Future<void> _eliminarConcepto(Concepto concepto) async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar el concepto "${concepto.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final database = context.read<AppDatabase>();
      
      // Verificar si tiene hijos
      if (_hasChildren(concepto.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede eliminar un concepto con hijos'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await database.deleteConcepto(concepto.id);
      
      if (_selectedConcepto?.id == concepto.id) {
        setState(() => _selectedConcepto = null);
      }
      
      await _loadConceptos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Concepto eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar concepto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailPanel() {
    if (_selectedConcepto == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona un concepto del árbol\npara ver sus detalles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final concepto = _selectedConcepto!;
    final hasChildren = _hasChildren(concepto.id);

    // Si tiene hijos y NO se forzó mostrar formulario, mostrar lista de hijos
    if (hasChildren && !_forceShowForm) {
      return _buildChildrenList(concepto);
    }

    // Si no tiene hijos o se forzó mostrar formulario, mostrar formulario de edición
    return ConceptoFormView(
      concepto: concepto,
      onBack: () {
        _loadConceptos();
      },
    );
  }

  Widget _buildChildrenList(Concepto padre) {
    final children = _getChildrenConceptos(padre.id);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getIconForTipoRecurso(padre.tipoRecurso),
                size: 24,
                color: _getColorForTipoRecurso(padre.tipoRecurso),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            padre.codigo,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            padre.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${children.length} concepto${children.length != 1 ? 's' : ''} hijo${children.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Lista de hijos
        Expanded(
          child: ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final importe = child.cantidad * child.coste;
              final isEditingCodigo = _editingConceptoId == child.id && _editingField == 'codigo';
              final isEditingNombre = _editingConceptoId == child.id && _editingField == 'nombre';
              final isEditingCantidad = _editingConceptoId == child.id && _editingField == 'cantidad';
              final isEditingCoste = _editingConceptoId == child.id && _editingField == 'coste';
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForTipoRecurso(child.tipoRecurso),
                      size: 20,
                      color: _getColorForTipoRecurso(child.tipoRecurso),
                    ),
                    const SizedBox(width: 12),
                    // Código editable
                    SizedBox(
                      width: 100,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _editingConceptoId = child.id;
                            _editingField = 'codigo';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEditingCodigo ? Colors.blue.shade50 : Colors.transparent,
                            border: Border.all(
                              color: isEditingCodigo ? Colors.blue : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isEditingCodigo
                              ? TextField(
                                  controller: _getOrCreateControllerText(child.id, 'codigo', child.codigo),
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _saveInlineEdit(child, 'codigo'),
                                  onTapOutside: (_) => _saveInlineEdit(child, 'codigo'),
                                )
                              : Text(
                                  child.codigo,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre editable
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _editingConceptoId = child.id;
                            _editingField = 'nombre';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEditingNombre ? Colors.blue.shade50 : Colors.transparent,
                            border: Border.all(
                              color: isEditingNombre ? Colors.blue : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isEditingNombre
                              ? TextField(
                                  controller: _getOrCreateControllerText(child.id, 'nombre', child.nombre),
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _saveInlineEdit(child, 'nombre'),
                                  onTapOutside: (_) => _saveInlineEdit(child, 'nombre'),
                                )
                              : Text(
                                  child.nombre,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Cantidad editable
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _editingConceptoId = child.id;
                            _editingField = 'cantidad';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEditingCantidad ? Colors.blue.shade50 : Colors.transparent,
                            border: Border.all(
                              color: isEditingCantidad ? Colors.blue : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isEditingCantidad
                              ? TextField(
                                  controller: _getOrCreateControllerNumber(child.id, 'cantidad', child.cantidad),
                                  autofocus: true,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _saveInlineEdit(child, 'cantidad'),
                                  onTapOutside: (_) => _saveInlineEdit(child, 'cantidad'),
                                )
                              : Text(
                                  child.cantidad.toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 13),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Coste editable
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _editingConceptoId = child.id;
                            _editingField = 'coste';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEditingCoste ? Colors.blue.shade50 : Colors.transparent,
                            border: Border.all(
                              color: isEditingCoste ? Colors.blue : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isEditingCoste
                              ? TextField(
                                  controller: _getOrCreateControllerNumber(child.id, 'coste', child.coste),
                                  autofocus: true,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _saveInlineEdit(child, 'coste'),
                                  onTapOutside: (_) => _saveInlineEdit(child, 'coste'),
                                )
                              : Text(
                                  '${_getMonedaSigno()}${child.coste.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 13),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Importe (solo lectura)
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${_getMonedaSigno()}${importe.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Subtotales
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'SUBTOTALES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Text(
                  children.fold<double>(0, (sum, c) => sum + c.cantidad).toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 1,
                child: Text(''),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Text(
                  '${_getMonedaSigno()}${children.fold<double>(0, (sum, c) => sum + (c.cantidad * c.coste)).toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Conceptos - ${widget.presupuesto.nombre}'),
        backgroundColor: settings.themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Recalcular Totales',
            onPressed: _isLoading ? null : _recalcularTotales,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Panel izquierdo - Árbol
                SizedBox(
                  width: _leftPanelWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_tree,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Árbol de Conceptos',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onSecondaryTapDown: (details) {
                              _showContextMenuForPresupuesto(context, details.globalPosition);
                            },
                            child: _conceptos.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No hay conceptos',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _nuevoConceptoRaiz(),
                                          icon: const Icon(Icons.add, size: 20),
                                          label: const Text('Crear Primer Capítulo'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView(
                                    children: _getChildrenConceptos(null)
                                        .map((concepto) => _buildTreeNode(concepto, 0))
                                        .toList(),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divisor arrastrable
                MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _leftPanelWidth = (_leftPanelWidth + details.delta.dx).clamp(200.0, 800.0);
                      });
                    },
                    child: Container(
                      width: 8,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                // Panel derecho - Detalle
                Expanded(
                  child: Container(
                    color: const Color(0xFFF0F0F0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Detalle del Concepto',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildDetailPanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Presupuesto: ${widget.presupuesto.nombre}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              '${_conceptos.length} concepto${_conceptos.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
