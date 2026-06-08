import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingrediente_provider.dart';
import '../providers/receita_ingrediente_provider.dart';
import '../models/receita_ingrediente.dart';

class ModalFichaTecnica extends StatefulWidget {
  final int receitaIdPre;

  const ModalFichaTecnica({super.key, required this.receitaIdPre});

  @override
  State<ModalFichaTecnica> createState() => _ModalFichaTecnicaState();
}

class _ModalFichaTecnicaState extends State<ModalFichaTecnica> {
  final _qtdCtrl = TextEditingController();
  dynamic _ingredienteSelecionado;
  String _unidadeSelecionada = 'g';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientes = context.watch<IngredienteProvider>().ingredientes;
    final provider = context.watch<ReceitaIngredienteProvider>();
    final rascunho = provider.itensRascunho
        .where((i) => i.receitaId == widget.receitaIdPre)
        .toList();

    return AlertDialog(
      title: const Text("Montar Ficha Técnica"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<dynamic>(
                    isExpanded: true,
                    hint: const Text("Selecione o Ingrediente"),
                    value: _ingredienteSelecionado,
                    items: ingredientes
                        .map(
                          (ing) => DropdownMenuItem(
                            value: ing,
                            child: Text(ing.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _ingredienteSelecionado = v),
                    validator: (v) => v == null ? "Obrigatório" : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtdCtrl,
                          decoration: const InputDecoration(labelText: 'Qtd'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _unidadeSelecionada,
                        items: ['kg', 'g', 'ml', 'L', 'un']
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _unidadeSelecionada = v!),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.orange,
                          size: 30,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _ingredienteSelecionado != null) {
                            final id = _ingredienteSelecionado.id!;
                            // VALIDAÇÃO REINSERIDA:
                            final jaNoBanco = provider
                                .itensDaReceita(widget.receitaIdPre)
                                .any((i) => i.ingredienteId == id);
                            final jaNoRascunho = provider.itensRascunho.any(
                              (i) => i.ingredienteId == id,
                            );

                            if (jaNoBanco || jaNoRascunho) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Atenção"),
                                  content: Text(
                                    "O ingrediente '${_ingredienteSelecionado.nome}' já foi adicionado!",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              provider.adicionarAoRascunho(
                                ReceitaIngrediente(
                                  id: null,
                                  receitaId: widget.receitaIdPre,
                                  ingredienteId: id,
                                  quantidade:
                                      double.tryParse(
                                        _qtdCtrl.text.replaceAll(',', '.'),
                                      ) ??
                                      0,
                                  unidade: _unidadeSelecionada,
                                  ingrediente: _ingredienteSelecionado,
                                ),
                              );
                              _qtdCtrl.clear();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: rascunho.length,
                itemBuilder: (ctx, i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    rascunho[i].ingrediente?.nome ?? "",
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${rascunho[i].quantidade} ${rascunho[i].unidade}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          final indexGlobal = provider.itensRascunho.indexOf(
                            rascunho[i],
                          );
                          provider.removerDoRascunho(indexGlobal);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCELAR"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: rascunho.isEmpty
              ? null
              : () async {
                  await provider.salvarFichaCompleta(widget.receitaIdPre);
                  if (mounted) Navigator.pop(context);
                },
          child: const Text(
            "SALVAR TUDO",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
