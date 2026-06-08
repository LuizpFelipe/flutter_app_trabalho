import 'package:flutter/material.dart';

class ConfirmarExclusaoModal extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final Future<void> Function() onConfirmar;

  const ConfirmarExclusaoModal({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Não'),
        ),
        TextButton(
          onPressed: () async {
            await onConfirmar();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text(
            'Sim',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
