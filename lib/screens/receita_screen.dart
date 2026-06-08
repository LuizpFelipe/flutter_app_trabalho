import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receita_provider.dart';
import '../models/receita.dart';
import '../components/receita_card.dart';
import '../components/formulario_receita_modal.dart';
import '../components/confirmar_exclusao_modal.dart';

class ReceitaScreen extends StatefulWidget {
  const ReceitaScreen({super.key});

  @override
  State<ReceitaScreen> createState() => _ReceitaScreenState();
}

class _ReceitaScreenState extends State<ReceitaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceitaProvider>().listar();
    });
  }

  void _abrirFormulario({Receita? receita}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FormularioReceitaModal(
        receita: receita,
        onSalvar: (nome, rendimento, imagem) async {
          final p = context.read<ReceitaProvider>();
          receita == null
              ? await p.criar(nome, rendimento, imagem, context)
              : await p.editar(receita.id!, nome, rendimento, imagem, context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceitaProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : provider.receitas.isEmpty
          ? const Center(child: Text("Nenhuma receita encontrada."))
          : RefreshIndicator(
              onRefresh: () => provider.listar(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: provider.receitas.length,
                itemBuilder: (ctx, i) => ReceitaCard(
                  receita: provider.receitas[i],
                  onEdit: () => _abrirFormulario(receita: provider.receitas[i]),
                  onDelete: () => showDialog(
                    context: context,
                    builder: (ctx) => ConfirmarExclusaoModal(
                      titulo: 'Excluir Receita',
                      mensagem:
                          'Deseja excluir "${provider.receitas[i].nome}"?',
                      onConfirmar: () => context
                          .read<ReceitaProvider>()
                          .excluir(provider.receitas[i].id!, context),
                    ),
                  ),
                ),
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
