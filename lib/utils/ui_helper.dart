import 'package:flutter/material.dart';

class UIHelper {
  static Future<bool> confirmarCorrecao(
    BuildContext context,
    String sugestao,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("         Atenção"),
        content: Text(
          "Você quis dizer: '$sugestao'. Deseja aplicar esta correção?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Manter"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Corrigir"),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
