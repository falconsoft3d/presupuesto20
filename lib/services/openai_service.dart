import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;
  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';

  OpenAIService({required this.apiKey});

  Future<String> sendMessage(String message, List<Map<String, String>> conversationHistory) async {
    if (apiKey.isEmpty || apiKey.trim().isEmpty) {
      throw Exception('Token de API no configurado. Por favor, configura tu token en Configuración > Integración.');
    }

    try {
      final messages = [
        ...conversationHistory,
        {'role': 'user', 'content': message},
      ];

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 401) {
        throw Exception('Token de API inválido. Verifica tu token en Configuración > Integración.');
      } else if (response.statusCode == 429) {
        throw Exception('Límite de uso excedido. Por favor, intenta más tarde.');
      } else if (response.statusCode == 500 || response.statusCode == 502 || response.statusCode == 503) {
        throw Exception('Error del servidor de OpenAI. Por favor, intenta más tarde.');
      } else {
        try {
          final error = jsonDecode(utf8.decode(response.bodyBytes));
          throw Exception(error['error']['message'] ?? 'Error desconocido (${response.statusCode})');
        } catch (_) {
          throw Exception('Error en la respuesta del servidor (${response.statusCode})');
        }
      }
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu conexión de red.');
    } on http.ClientException {
      throw Exception('Error de conexión. Verifica tu configuración de red o firewall.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }
}
