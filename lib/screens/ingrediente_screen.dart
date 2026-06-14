import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingrediente_provider.dart';
import '../models/ingrediente.dart';
import '../components/ingrediente_card.dart';
import '../components/formulario_ingrediente_modal.dart';
import '../components/confirmar_exclusao_modal.dart';

class IngredienteScreen extends StatefulWidget {
  const IngredienteScreen({super.key});

  @override
  State<IngredienteScreen> createState() => _IngredienteScreenState();
}

class _IngredienteScreenState extends State<IngredienteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredienteProvider>().listar();
    });
  }

  void _abrirFormulario({Ingrediente? ingrediente}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FormularioIngredienteModal(
        ingrediente: ingrediente,
        onSalvar: (nome, imagem) async {
          final p = context.read<IngredienteProvider>();
          ingrediente == null
              ? await p.criar(nome, imagem, context)
              : await p.editar(ingrediente.id!, nome, imagem, context);
        },
      ),
    );
  }

  void _confirmarExclusao(Ingrediente item) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmarExclusaoModal(
        titulo: 'Excluir Ingrediente',
        mensagem: 'Deseja realmente excluir "${item.nome}"?',
        onConfirmar: () async {
          Navigator.pop(ctx);

          final provider = context.read<IngredienteProvider>();
          final sucesso = await provider.excluir(item.id!, context);

          if (!sucesso && mounted) {
            showDialog(
              context: context,
              builder: (errorCtx) => AlertDialog(
                title: const Text(
                  "Não é possível excluir",
                  style: TextStyle(color: Colors.red),
                ),
                content: Text(
                  "O ingrediente '${item.nome}' está vinculado a uma ficha técnica. "
                  "Remova o vínculo antes de excluir.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(errorCtx),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IngredienteProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : provider.ingredientes.isEmpty
          ? const Center(child: Text("Nenhum ingrediente cadastrado."))
          : RefreshIndicator(
              onRefresh: () => provider.listar(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: provider.ingredientes.length,
                itemBuilder: (ctx, i) {
                  final item = provider.ingredientes[i];
                  return IngredienteCard(
                    ingrediente: item,
                    onEdit: () => _abrirFormulario(ingrediente: item),
                    onDelete: () => _confirmarExclusao(item),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
