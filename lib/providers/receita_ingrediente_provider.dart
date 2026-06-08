import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/receita_ingrediente.dart';

class ReceitaIngredienteProvider with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.92:8000",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  final Map<int, List<ReceitaIngrediente>> _itensPorReceita = {};
  List<ReceitaIngrediente> _itensRascunho = [];
  bool _isLoading = false;

  ReceitaIngredienteProvider() {
    _carregarRascunho();
  }

  bool get isLoading => _isLoading;
  List<ReceitaIngrediente> get itensRascunho => [..._itensRascunho];

  List<ReceitaIngrediente> itensDaReceita(int receitaId) {
    return _itensPorReceita[receitaId] ?? [];
  }

  Future<void> _gravarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = jsonEncode(_itensRascunho.map((e) => e.toJson()).toList());
    await prefs.setString('rascunho_ficha_tecnica', jsonList);
  }

  Future<void> _carregarRascunho() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('rascunho_ficha_tecnica');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _itensRascunho = decoded
          .map((e) => ReceitaIngrediente.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  void adicionarAoRascunho(ReceitaIngrediente item) {
    _itensRascunho.add(item);
    _gravarRascunho();
    notifyListeners();
  }

  void removerDoRascunho(int index) {
    _itensRascunho.removeAt(index);
    _gravarRascunho();
    notifyListeners();
  }

  void limparRascunho() {
    _itensRascunho = [];
    _gravarRascunho();
    notifyListeners();
  }

  Future<void> listarPorReceita(int receitaId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get(
        '/receita-ingrediente/receita/$receitaId',
      );
      if (response.statusCode == 200) {
        _itensPorReceita[receitaId] = (response.data as List)
            .map((item) => ReceitaIngrediente.fromJson(item))
            .toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvarFichaCompleta(int receitaId) async {
    if (_itensRascunho.isEmpty) return;

    try {
      final payload = {
        "receita_id": receitaId,
        "itens": _itensRascunho.map((i) => i.toJson()).toList(),
      };

      final response = await _dio.post(
        '/receita-ingrediente/lote',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        limparRascunho();
        await listarPorReceita(receitaId);
      }
    } on DioException catch (e) {
      debugPrint("Erro ao salvar lote: ${e.message}");
    }
  }

  Future<void> editarInsumo(
    int id,
    int receitaId,
    double novaQtd,
    String novaUnidade,
  ) async {
    try {
      final response = await _dio.patch(
        '/receita-ingrediente/$id',
        queryParameters: {'quantidade': novaQtd, 'unidade': novaUnidade},
      );
      if (response.statusCode == 200) {
        await listarPorReceita(receitaId);
      }
    } on DioException catch (e) {
      debugPrint("Erro ao editar insumo: ${e.message}");
    }
  }

  Future<void> excluirInsumo(int id, int receitaId) async {
    try {
      final response = await _dio.delete('/receita-ingrediente/$id');
      if (response.statusCode == 200) {
        await listarPorReceita(receitaId);
      }
    } on DioException catch (e) {
      debugPrint("Erro ao excluir item: ${e.message}");
    }
  }

  Future<void> excluirFichaCompleta(int receitaId) async {
    try {
      final response = await _dio.delete(
        '/receita-ingrediente/limpar-ficha/$receitaId',
      );
      if (response.statusCode == 200) {
        _itensPorReceita[receitaId] = [];
        notifyListeners();
      }
    } on DioException catch (e) {
      debugPrint("Erro ao limpar ficha: ${e.message}");
    }
  }
}
