import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/receita.dart';
import '../providers/receita_ingrediente_provider.dart';
import 'ficha_detalhe_widget.dart';

class FichaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onLimpar;
  final VoidCallback onAdicionarInsumo;

  const FichaCard({
    super.key,
    required this.receita,
    required this.onLimpar,
    required this.onAdicionarInsumo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      color: Colors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 4,
            bottom: 4,
          ),
          onExpansionChanged: (exp) {
            if (exp) {
              context.read<ReceitaIngredienteProvider>().listarPorReceita(
                receita.id!,
              );
            }
          },
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFD9E5D6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                receita.urlCompleta,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Icon(
                  Icons.restaurant_menu_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
            ),
          ),
          title: Text(
            receita.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.scale_rounded,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Rendimento: ${receita.rendimentoPadrao} unid/kg',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            FichaDetalheWidget(receitaId: receita.id!),
            Divider(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      // Confirmação antes de chamar a função de limpar
                      bool confirmar =
                          await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Limpar Ficha"),
                              content: Text(
                                "Tem certeza que deseja remover todos os ingredientes da receita '${receita.nome}'?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Limpar"),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (confirmar) {
                        onLimpar();
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      "Limpar Ficha",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onAdicionarInsumo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE88D43),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text(
                      "Ingrediente",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
