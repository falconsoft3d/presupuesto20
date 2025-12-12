import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:io';
import '../database/database.dart';
import '../providers/auth_provider.dart';

class ConceptoComentariosScreen extends StatefulWidget {
  final Concepto concepto;

  const ConceptoComentariosScreen({
    Key? key,
    required this.concepto,
  }) : super(key: key);

  @override
  State<ConceptoComentariosScreen> createState() => _ConceptoComentariosScreenState();
}

class _ConceptoComentariosScreenState extends State<ConceptoComentariosScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  late AppDatabase _database;
  
  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    if (_mensajeController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await _database.insertMensajeConcepto(
      MensajesConceptosCompanion.insert(
        conceptoId: widget.concepto.id,
        usuarioId: drift.Value(authProvider.currentUser?.id),
        mensaje: _mensajeController.text.trim(),
      ),
    );

    _mensajeController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje enviado')),
      );
    }
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await _database.insertAdjuntoConcepto(
        AdjuntosConceptosCompanion.insert(
          conceptoId: widget.concepto.id,
          usuarioId: drift.Value(authProvider.currentUser?.id),
          nombreArchivo: result.files.single.name,
          rutaArchivo: result.files.single.path!,
          tipoArchivo: result.files.single.extension ?? 'unknown',
          tamanoBytes: await file.length(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archivo adjuntado')),
        );
      }
    }
  }

  Future<void> _eliminarMensaje(int id) async {
    await _database.deleteMensajeConcepto(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje eliminado')),
      );
    }
  }

  Future<void> _eliminarAdjunto(int id) async {
    await _database.deleteAdjuntoConcepto(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adjunto eliminado')),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios - ${widget.concepto.nombre}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header con info del concepto
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.concepto.codigo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.concepto.nombre,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.message), text: 'Mensajes'),
                      Tab(icon: Icon(Icons.attach_file), text: 'Adjuntos'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab de Mensajes
                        Column(
                          children: [
                            Expanded(
                              child: StreamBuilder<List<MensajeConcepto>>(
                                stream: _database.watchMensajesConcepto(widget.concepto.id),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  final mensajes = snapshot.data!;
                                  
                                  if (mensajes.isEmpty) {
                                    return const Center(
                                      child: Text('No hay mensajes aún'),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: mensajes.length,
                                    itemBuilder: (context, index) {
                                      final mensaje = mensajes[index];
                                      final esPropio = mensaje.usuarioId == authProvider.currentUser?.id;
                                      
                                      return Align(
                                        alignment: esPropio 
                                            ? Alignment.centerRight 
                                            : Alignment.centerLeft,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                                          ),
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: esPropio 
                                                ? Colors.blue[100] 
                                                : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mensaje.mensaje,
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    DateFormat('dd/MM/yyyy HH:mm').format(mensaje.fechaCreacion),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  if (esPropio) ...[
                                                    const SizedBox(width: 8),
                                                    InkWell(
                                                      onTap: () => _eliminarMensaje(mensaje.id),
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 16,
                                                        color: Colors.red[400],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Campo de entrada
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _mensajeController,
                                      decoration: const InputDecoration(
                                        hintText: 'Escribe un mensaje...',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _enviarMensaje(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _enviarMensaje,
                                    icon: const Icon(Icons.send),
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Tab de Adjuntos
                        Column(
                          children: [
                            Expanded(
                              child: StreamBuilder<List<AdjuntoConcepto>>(
                                stream: _database.watchAdjuntosConcepto(widget.concepto.id),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  final adjuntos = snapshot.data!;
                                  
                                  if (adjuntos.isEmpty) {
                                    return const Center(
                                      child: Text('No hay adjuntos aún'),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: adjuntos.length,
                                    itemBuilder: (context, index) {
                                      final adjunto = adjuntos[index];
                                      final esPropio = adjunto.usuarioId == authProvider.currentUser?.id;
                                      
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        child: ListTile(
                                          leading: Icon(
                                            _getFileIcon(adjunto.tipoArchivo),
                                            size: 32,
                                            color: Colors.blue,
                                          ),
                                          title: Text(adjunto.nombreArchivo),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_formatBytes(adjunto.tamanoBytes)),
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm').format(adjunto.fechaCreacion),
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.open_in_new),
                                                onPressed: () {
                                                  // Abrir archivo
                                                  final file = File(adjunto.rutaArchivo);
                                                  if (file.existsSync()) {
                                                    // En macOS se puede usar 'open'
                                                    Process.run('open', [adjunto.rutaArchivo]);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Archivo no encontrado')),
                                                    );
                                                  }
                                                },
                                                tooltip: 'Abrir',
                                              ),
                                              if (esPropio)
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _eliminarAdjunto(adjunto.id),
                                                  tooltip: 'Eliminar',
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Botón agregar adjunto
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: ElevatedButton.icon(
                                onPressed: _seleccionarArchivo,
                                icon: const Icon(Icons.attach_file),
                                label: const Text('Adjuntar archivo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}
