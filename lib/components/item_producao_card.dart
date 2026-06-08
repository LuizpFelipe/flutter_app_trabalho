import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receita_provider.dart';

class ItemProducaoCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemover;

  const ItemProducaoCard({
    super.key,
    required this.item,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final receitas = context.watch<ReceitaProvider>().receitas;

    if (receitas.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ListTile(title: Text("Carregando...")),
      );
    }

    final receitaOriginal = receitas.cast<dynamic>().firstWhere(
      (r) =>
          r.id == item['receita_id'] ||
          r.id == item['id'] ||
          r.nome == item['nome'],
      orElse: () => null,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                (receitaOriginal != null && receitaOriginal.urlCompleta != null)
                ? Image.network(
                    receitaOriginal.urlCompleta,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        const Icon(Icons.broken_image),
                  )
                : const Icon(Icons.restaurant, color: Colors.deepPurple),
          ),
        ),
        title: Text(
          item['nome'] ?? 'Receita desconhecida',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Quantidade: ${item['quantidade'] ?? 0}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemover,
        ),
      ),
    );
  }
}
