import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class InteligenciaProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://192.168.1.92:8000"));

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
