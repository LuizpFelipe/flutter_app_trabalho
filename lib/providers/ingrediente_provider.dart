import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/ingrediente.dart';

class IngredienteProvider extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.92:8000",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  List<Ingrediente> _ingredientes = [];
  bool _isLoading = false;

  List<Ingrediente> get ingredientes => _ingredientes;
  bool get isLoading => _isLoading;

  Future<void> listar() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('/ingredientes/');
      _ingredientes = (response.data as List)
          .map((i) => Ingrediente.fromJson(i))
          .toList();
    } catch (e) {
      debugPrint("Erro ao listar: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> criar(
    String nome,
    File? arquivoImagem,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> data = {
        "nome": nome,
        if (arquivoImagem != null)
          "file": await MultipartFile.fromFile(
            arquivoImagem.path,
            filename: arquivoImagem.path.split('/').last,
          ),
      };

      await _dio.post('/ingredientes/', data: FormData.fromMap(data));
      await listar();

      if (context.mounted) {
        _mostrarSnackBar(
          context,
          "Ingrediente criado com sucesso!",
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint("Erro ao criar: $e");
      if (context.mounted) {
        _mostrarSnackBar(context, "Erro ao criar ingrediente", Colors.red);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editar(
    int id,
    String novoNome,
    File? arquivoImagem,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> data = {
        "nome": novoNome,
        if (arquivoImagem != null)
          "file": await MultipartFile.fromFile(
            arquivoImagem.path,
            filename: arquivoImagem.path.split('/').last,
          ),
      };

      await _dio.patch('/ingredientes/$id', data: FormData.fromMap(data));
      await listar();

      if (context.mounted) {
        _mostrarSnackBar(
          context,
          "Ingrediente atualizado com sucesso!",
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint("Erro ao editar: $e");
      if (context.mounted) {
        _mostrarSnackBar(context, "Erro ao atualizar ingrediente", Colors.red);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> excluir(int id, BuildContext context) async {
    try {
      await _dio.delete('/ingredientes/$id');
      _ingredientes.removeWhere((i) => i.id == id);
      notifyListeners();
      if (context.mounted) {
        _mostrarSnackBar(context, "Ingrediente removido!", Colors.green);
      }
    } on DioException catch (e) {
      String mensagem = "Erro ao excluir";
      if (e.response != null && e.response?.data is Map) {
        mensagem = e.response?.data['detail'] ?? mensagem;
      }
      if (context.mounted) _mostrarSnackBar(context, mensagem, Colors.red);
    }
  }

  void _mostrarSnackBar(BuildContext context, String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: cor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
