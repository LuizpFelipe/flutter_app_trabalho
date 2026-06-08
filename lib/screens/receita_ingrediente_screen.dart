import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receita_provider.dart';
import '../providers/ingrediente_provider.dart';
import '../providers/receita_ingrediente_provider.dart';
import '../components/ficha_card.dart';
import '../components/modal_ficha_tecnica.dart';

class ReceitaIngredienteScreen extends StatefulWidget {
  const ReceitaIngredienteScreen({super.key});

  @override
  State<ReceitaIngredienteScreen> createState() =>
      _ReceitaIngredienteScreenState();
}

class _ReceitaIngredienteScreenState extends State<ReceitaIngredienteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceitaProvider>().listar();
      context.read<IngredienteProvider>().listar();
    });
  }

  void _confirmarExclusaoTotal(BuildContext context, dynamic receita) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Ficha Técnica?"),
        content: Text("Isso removerá todos os insumos de '${receita.nome}'."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("VOLTAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context
                  .read<ReceitaIngredienteProvider>()
                  .excluirFichaCompleta(receita.id!);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("LIMPAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirModalFicha({required int receitaIdPre}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ModalFichaTecnica(receitaIdPre: receitaIdPre),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receitas = context.watch<ReceitaProvider>().receitas;
    final provider = context.watch<ReceitaIngredienteProvider>();

    return Scaffold(
      body: ListView.builder(
        itemCount: receitas.length,
        itemBuilder: (ctx, i) {
          final receita = receitas[i];
          final pendentes = provider.itensRascunho
              .where((item) => item.receitaId == receita.id)
              .toList();

          return Column(
            children: [
              FichaCard(
                receita: receita,
                onLimpar: () => _confirmarExclusaoTotal(context, receita),
                onAdicionarInsumo: () =>
                    _abrirModalFicha(receitaIdPre: receita.id!),
              ),
              if (pendentes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      "SALVAR ${pendentes.length} NOVOS INGREDIENTES",
                    ),
                    onPressed: () async {
                      await provider.salvarFichaCompleta(receita.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Ficha técnica atualizada com sucesso!",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
