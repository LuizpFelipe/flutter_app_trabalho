import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/receita.dart';

class ReceitaProvider extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.92:8000",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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

      String mensagemErroDoServidor = "Erro ao excluir receita.";

      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is Map && e.response!.data['detail'] != null) {
          mensagemErroDoServidor = e.response!.data['detail'];
        }
      }

      if (context.mounted) {
        _mostrarMsg(context, mensagemErroDoServidor, Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarMsg(context, "Erro inesperado ao excluir.", Colors.red);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mostrarMsg(BuildContext context, String txt, Color cor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(txt), backgroundColor: cor));
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
}
