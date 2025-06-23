import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "https://ery-app-turso.vercel.app/api";

  // --- MÉTODO DE LOGIN (EXISTENTE) ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor.');
    }
  }

  // --- ¡NUEVO MÉTODO DE REGISTRO! ---
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/auth/register',
    ); // Apunta al endpoint correcto
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // Enviamos nombre, email y password en el cuerpo
        body: json.encode({
          'nombre': name,
          'email': email,
          'password': password,
        }),
      );
      // Reutilizamos el mismo manejador de respuestas
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión con el servidor.');
    }
  }

  // --- MANEJADOR DE RESPUESTAS (EXISTENTE) ---
  Map<String, dynamic> _handleResponse(http.Response response) {
    // Decodifica el cuerpo de la respuesta solo si no está vacío.
    final responseBody =
        response.body.isNotEmpty ? json.decode(response.body) : {};

    // Si la respuesta es exitosa (código 200-299), la devuelve.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Si hay un error, extrae el mensaje del backend y lo lanza como una excepción.
      throw Exception(
        responseBody['message'] ?? 'Ocurrió un error desconocido.',
      );
    }
  }

  // Aquí podemos seguir añadiendo los demás métodos (hábitos, perfil, etc.)
  // cuando los necesitemos. Por ahora, con login y register es suficiente.
}
