import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProducaoProvider extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://192.168.1.92:8000"));

  Map<int, Map<String, dynamic>> _itensCarrinho = {};
  List<dynamic> _listaCompras = [];
  bool _isLoading = false;

  Map<int, Map<String, dynamic>> get itensCarrinho => _itensCarrinho;
  List<dynamic> get listaCompras => _listaCompras;
  bool get isLoading => _isLoading;

  void adicionarAoCarrinho(int id, String nome, double qtd) {
    if (qtd <= 0) return;
    _itensCarrinho[id] = {'nome': nome, 'quantidade': qtd};
    notifyListeners();
  }

  void removerDoCarrinho(int id) {
    _itensCarrinho.remove(id);
    notifyListeners();
  }

  void limparCarrinho() {
    _itensCarrinho.clear();
    _listaCompras.clear();
    notifyListeners();
  }

  Future<void> calcularLista() async {
    if (_itensCarrinho.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        '/receita-ingrediente/lista-compras',
        data: {
          "itens": _itensCarrinho.entries
              .map(
                (e) => {
                  "receita_id": e.key,
                  "quantidade_produzir": e.value['quantidade'],
                },
              )
              .toList(),
        },
      );
      _listaCompras = response.data;
    } catch (e) {
      debugPrint("Erro ao calcular lista: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
