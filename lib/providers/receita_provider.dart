import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/receita.dart';

class ReceitaProvider extends ChangeNotifier {
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

  List<Receita> _receitas = [];
  bool _isLoading = false;

  List<Receita> get receitas => _receitas;
  bool get isLoading => _isLoading;

  Future<void> listar() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('/receitas/');
      _receitas = (response.data as List)
          .map((r) => Receita.fromJson(r))
          .toList();
    } on DioException catch (e) {
      debugPrint("Erro ao listar receitas: ${e.message}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> criar(
    String nome,
    int rendimentoPadrao,
    File? arquivoImagem,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      FormData formData = FormData.fromMap({
        "nome": nome,
        "rendimento_padrao": rendimentoPadrao,
        if (arquivoImagem != null)
          "file": await MultipartFile.fromFile(
            arquivoImagem.path,
            filename: arquivoImagem.path.split('/').last,
          ),
      });

      await _dio.post('/receitas/', data: formData);
      await listar();

      if (context.mounted) {
        _mostrarMsg(context, "Receita criada com sucesso!", Colors.green);
      }
    } catch (e) {
      debugPrint("Erro ao criar: $e");
      if (context.mounted) {
        _mostrarMsg(context, "Erro ao criar receita", Colors.red);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editar(
    int id,
    String nome,
    int rendimentoPadrao,
    File? arquivoImagem,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      FormData formData = FormData.fromMap({
        "nome": nome,
        "rendimento_padrao": rendimentoPadrao,
        if (arquivoImagem != null)
          "file": await MultipartFile.fromFile(
            arquivoImagem.path,
            filename: arquivoImagem.path.split('/').last,
          ),
      });

      await _dio.patch('/receitas/$id', data: formData);
      await listar();

      if (context.mounted) {
        _mostrarMsg(context, "Receita atualizada!", Colors.green);
      }
    } catch (e) {
      debugPrint("Erro ao editar: $e");
      if (context.mounted) {
        _mostrarMsg(context, "Erro ao editar receita", Colors.red);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> excluir(int id, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _dio.delete('/receitas/$id');
      _receitas.removeWhere((r) => r.id == id);

      if (context.mounted) {
        _mostrarMsg(context, "Receita removida com sucesso!", Colors.green);
      }
    } on DioException catch (e) {
      debugPrint("Erro ao excluir: ${e.message}");
      String msg = "Erro ao excluir receita.";
      if (e.response?.data != null && e.response!.data is Map) {
        msg = e.response!.data['detail'] ?? msg;
      }
      if (context.mounted) _mostrarMsg(context, msg, Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verificarSugestaoNome(String nome) async {
    try {
      final response = await _dio.get(
        '/inteligencia/normalizar-nome',
        queryParameters: {'termo': nome},
      );
      return response.data['sugestao'];
    } catch (e) {
      debugPrint("Erro ao verificar sugestão de nome: $e");
      return null;
    }
  }

  void _mostrarMsg(BuildContext context, String txt, Color cor) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(txt), backgroundColor: cor));
  }
}
