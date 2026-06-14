import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class InteligenciaProvider with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://romantic-appreciation-production-6580.up.railway.app",
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      followRedirects: true,
      maxRedirects: 5,
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<String?> normalizarNome(String nome) async {
    if (nome.trim().isEmpty) return null;

    try {
      final response = await _dio.get(
        '/inteligencia/normalizar-nome',
        queryParameters: {'termo': nome},
      );

      final String? sugestao = response.data['sugestao'];

      if (sugestao != null &&
          sugestao.trim().toLowerCase() != nome.trim().toLowerCase()) {
        return sugestao;
      }

      return null;
    } catch (e) {
      debugPrint("Erro na Inteligência: $e");
      return null;
    }
  }
}
