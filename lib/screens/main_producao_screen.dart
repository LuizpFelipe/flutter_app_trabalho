import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receita_provider.dart';
import '../providers/producao_provider.dart';
import '../components/lista_compras_modal.dart';
import '../components/item_producao_card.dart';

class MainProductionScreen extends StatefulWidget {
  const MainProductionScreen({super.key});

  @override
  State<MainProductionScreen> createState() => _MainProductionScreenState();
}

class _MainProductionScreenState extends State<MainProductionScreen> {
  int? _receitaSelecionadaId;
  String? _receitaSelecionadaNome;
  final _qtdController = TextEditingController();
  final FocusNode _qtdFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceitaProvider>().listar();
    });
  }

  @override
  void dispose() {
    _qtdController.dispose();
    _qtdFocusNode.dispose();
    super.dispose();
  }

  void _exibirListaCompras() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const ListaComprasModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receitas = context.watch<ReceitaProvider>().receitas;
    final producao = context.watch<ProducaoProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _receitaSelecionadaId,
              decoration: const InputDecoration(
                labelText: 'Selecione a Receita',
                border: OutlineInputBorder(),
              ),
              items: receitas
                  .map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.nome)),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _receitaSelecionadaId = val;
                  _receitaSelecionadaNome = receitas
                      .firstWhere((r) => r.id == val)
                      .nome;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _qtdController,
              focusNode: _qtdFocusNode,
              decoration: const InputDecoration(
                labelText: 'Quantidade a Produzir',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_receitaSelecionadaId != null &&
                      _qtdController.text.isNotEmpty) {
                    final qtd =
                        double.tryParse(
                          _qtdController.text.replaceAll(',', '.'),
                        ) ??
                        0;
                    if (qtd > 0) {
                      producao.adicionarAoCarrinho(
                        _receitaSelecionadaId!,
                        _receitaSelecionadaNome!,
                        qtd,
                      );
                      _qtdController.clear();
                      _qtdFocusNode.unfocus();
                    }
                  }
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("ADICIONAR À PRODUÇÃO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Receitas Selecionadas:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (producao.itensCarrinho.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                    ),
                    tooltip: "Limpar Lista",
                    onPressed: () async {
                      bool confirmar =
                          await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Limpar Lista"),
                              content: const Text(
                                "Deseja remover todas as receitas da lista de produção?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Limpar Tudo"),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (confirmar) producao.limparCarrinho();
                    },
                  ),
              ],
            ),

            Expanded(
              child: producao.itensCarrinho.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhuma receita selecionada.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: producao.itensCarrinho.length,
                      itemBuilder: (ctx, i) {
                        final key = producao.itensCarrinho.keys.elementAt(i);
                        final item = producao.itensCarrinho[key]!;
                        return ItemProducaoCard(
                          item: item,
                          onRemover: () async {
                            bool confirmar =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Remover Receita"),
                                    content: Text(
                                      "Deseja remover ${item['nome']} da lista?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text("Remover"),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (confirmar) producao.removerDoCarrinho(key);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: producao.itensCarrinho.isNotEmpty
          ? [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await producao.calcularLista();
                    _exibirListaCompras();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("GERAR LISTA DE PRODUÇÃO"),
                ),
              ),
            ]
          : null,
    );
  }
}
