import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receita_ingrediente_provider.dart';
import '../models/receita_ingrediente.dart';

class FichaDetalheWidget extends StatelessWidget {
  final int receitaId;
  const FichaDetalheWidget({super.key, required this.receitaId});

  void _confirmarExclusao(BuildContext context, ReceitaIngrediente item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.orange),
            SizedBox(width: 10),
            Text("Remover Insumo"),
          ],
        ),
        content: Text(
          "Deseja realmente remover \"${item.ingrediente?.nome ?? 'Insumo'}\" desta ficha técnica?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ReceitaIngredienteProvider>().excluirInsumo(
                item.id!,
                receitaId,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              "REMOVER",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirModalEdicao(BuildContext context, ReceitaIngrediente item) {
    final qtdCtrl = TextEditingController(text: item.quantidade.toString());
    String unidadeSelecionada = item.unidade;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text("Editar ${item.ingrediente?.nome ?? 'Insumo'}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtdCtrl,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: unidadeSelecionada,
                decoration: const InputDecoration(labelText: 'Unidade'),
                items: ['kg', 'g', 'ml', 'L', 'un']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setModalState(() => unidadeSelecionada = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final novaQtd = double.tryParse(
                  qtdCtrl.text.replaceAll(',', '.'),
                );

                if (novaQtd == null || novaQtd <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("A quantidade deve ser maior que zero!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                await context.read<ReceitaIngredienteProvider>().editarInsumo(
                  item.id!,
                  receitaId,
                  novaQtd,
                  unidadeSelecionada,
                );
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceitaIngredienteProvider>();
    final meusItens = provider.itensDaReceita(receitaId);

    if (provider.isLoading && meusItens.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (meusItens.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "Nenhum ingrediente nesta ficha.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meusItens.length,
      itemBuilder: (ctx, i) {
        final item = meusItens[i];
        return ListTile(
          dense: true,
          leading: const Icon(Icons.shopping_basket_outlined, size: 20),
          title: Text(
            item.ingrediente?.nome ?? "Insumo",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text("${item.quantidade} ${item.unidade}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
                onPressed: () => _abrirModalEdicao(context, item),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () => _confirmarExclusao(context, item),
              ),
            ],
          ),
        );
      },
    );
  }
}
