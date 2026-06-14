import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/ingrediente.dart';

class IngredienteProvider extends ChangeNotifier {
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
        _mostrarSnackBar(context, "Ingrediente criado!", Colors.green);
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarSnackBar(context, "Erro ao criar", Colors.red);
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
        _mostrarSnackBar(context, "Ingrediente atualizado!", Colors.green);
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarSnackBar(context, "Erro ao atualizar", Colors.red);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> excluir(int id, BuildContext context) async {
    try {
      await _dio.delete('/ingredientes/$id');
      _ingredientes.removeWhere((i) => i.id == id);
      notifyListeners();

      if (context.mounted) {
        _mostrarSnackBar(context, "Removido com sucesso!", Colors.green);
      }
      return true;
    } catch (e) {
      // Retorna false silenciosamente para qualquer erro (vínculo ou servidor).
      // A tela (IngredienteScreen) cuidará de exibir o modal de aviso.
      return false;
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
