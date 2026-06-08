import 'package:flutter/material.dart';
import '../models/receita_ingrediente.dart';

class ItemRascunhoListTile extends StatelessWidget {
  final ReceitaIngrediente item;
  final VoidCallback onRemover;

  const ItemRascunhoListTile({
    super.key,
    required this.item,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(item.ingrediente?.nome ?? ""),
      subtitle: Text("${item.quantidade}${item.unidade}"),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        onPressed: onRemover,
      ),
    );
  }
}
