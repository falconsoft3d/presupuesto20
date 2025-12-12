import 'package:flutter/material.dart';
import '../database/database.dart';
import '../services/openai_service.dart';
import 'package:drift/drift.dart' as drift;

class ChatProvider with ChangeNotifier {
  final AppDatabase database;
  final OpenAIService openAIService;
  
  List<MensajeChat> _mensajes = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({
    required this.database,
    required this.openAIService,
  }) {
    _cargarMensajes();
  }

  List<MensajeChat> get mensajes => _mensajes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _cargarMensajes() async {
    _mensajes = await database.getAllMensajesChat();
    notifyListeners();
  }

  Future<void> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty) return;

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Guardar mensaje del usuario
      final mensajeUsuario = MensajesChatCompanion(
        mensaje: drift.Value(texto),
        rol: const drift.Value('user'),
      );
      await database.insertMensajeChat(mensajeUsuario);
      await _cargarMensajes();

      // Preparar historial de conversación
      final historial = _mensajes.map((m) => {
        'role': m.rol,
        'content': m.mensaje,
      }).toList();

      // Enviar a OpenAI
      final respuesta = await openAIService.sendMessage(texto, historial);

      // Guardar respuesta de la IA
      final mensajeAsistente = MensajesChatCompanion(
        mensaje: drift.Value(respuesta),
        rol: const drift.Value('assistant'),
      );
      await database.insertMensajeChat(mensajeAsistente);
      await _cargarMensajes();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> limpiarChat() async {
    await database.deleteAllMensajesChat();
    await _cargarMensajes();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
