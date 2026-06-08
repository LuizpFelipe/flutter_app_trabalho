import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/producao_provider.dart';

class ListaComprasModal extends StatelessWidget {
  const ListaComprasModal({super.key});

  void _compartilharListaNativo(
    BuildContext context,
    List<dynamic> itens,
  ) async {
    if (itens.isEmpty) return;

    String textoFinal = "📋 *LISTA DE PRODUÇÃO / INSUMOS*\n\n";
    for (var item in itens) {
      final nome = item['ingrediente'] ?? item['nome'] ?? 'Ingrediente';
      final qtd = item['quantidade'] ?? item['quantidade_total'] ?? 0;
      final unidade = item['unidade'] ?? '';

      textoFinal += "• $nome: $qtd $unidade\n";
    }

    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      textoFinal,
      subject: 'Lista de Insumos para Produção',
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProducaoProvider>(
      builder: (context, producao, child) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "📋 Lista de Produção",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: producao.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: producao.listaCompras.length,
                      itemBuilder: (ctx, i) {
                        final item = producao.listaCompras[i];

                        final nome =
                            item['ingrediente'] ??
                            item['nome'] ??
                            'Ingrediente';
                        final qtd =
                            item['quantidade'] ?? item['quantidade_total'] ?? 0;
                        final unidade = item['unidade'] ?? '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          leading: const Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.grey,
                          ),
                          title: Text(
                            nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$qtd $unidade",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _compartilharListaNativo(context, producao.listaCompras),
                icon: const Icon(Icons.share),
                label: const Text(
                  "COMPARTILHAR LISTA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
