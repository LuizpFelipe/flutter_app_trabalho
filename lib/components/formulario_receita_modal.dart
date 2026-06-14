import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_trabalho/utils/image_utils.dart';
import '../models/receita.dart';
import '../providers/receita_provider.dart';

class FormularioReceitaModal extends StatefulWidget {
  final Receita? receita;
  final Future<void> Function(String nome, int rendimento, File? imagem)
  onSalvar;

  const FormularioReceitaModal({
    super.key,
    this.receita,
    required this.onSalvar,
  });

  @override
  State<FormularioReceitaModal> createState() => _FormularioReceitaModalState();
}

class _FormularioReceitaModalState extends State<FormularioReceitaModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _rendimentoController;
  late String _nomeOriginal;
  File? _imagemSelecionada;
  bool _isSaving = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _nomeOriginal = widget.receita?.nome ?? '';
    _nomeController = TextEditingController(text: _nomeOriginal);
    _rendimentoController = TextEditingController(
      text: widget.receita?.rendimentoPadrao.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _rendimentoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final File? imagem = await ImageUtils.selecionarImagem(context);
    if (imagem != null) {
      setState(() => _imagemSelecionada = imagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.receita == null ? 'Nova Receita' : 'Editar Receita'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFD9E5D6),
                  backgroundImage: _imagemSelecionada != null
                      ? FileImage(_imagemSelecionada!)
                      : (widget.receita?.imagem != null
                            ? NetworkImage(widget.receita!.urlCompleta)
                                  as ImageProvider
                            : null),
                  child:
                      _imagemSelecionada == null &&
                          widget.receita?.imagem == null
                      ? Icon(
                          Icons.add_a_photo_rounded,
                          size: 32,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              if (_mensagemErro != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _mensagemErro!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Receita',
                  prefixIcon: Icon(
                    Icons.restaurant_menu,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Insira o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rendimentoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Rendimento Padrão',
                  suffixText: 'unid/kg',
                  prefixIcon: Icon(Icons.scale, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Valor inválido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() {
                    _isSaving = true;
                    _mensagemErro = null;
                  });

                  try {
                    String nomeAtual = _nomeController.text.trim();

                    if (nomeAtual != _nomeOriginal) {
                      final sugestao = await context
                          .read<ReceitaProvider>()
                          .verificarSugestaoNome(nomeAtual);

                      if (sugestao != null && context.mounted) {
                        bool aceitou =
                            await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Correção Inteligente"),
                                content: Text(
                                  "O sistema sugere '$sugestao'. Deseja corrigir?",
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
                            ) ??
                            false;
                        if (aceitou) nomeAtual = sugestao;
                      }
                    }
                    if (nomeAtual.toLowerCase() !=
                            _nomeOriginal.toLowerCase() &&
                        context.mounted) {
                      final receitaProvider = context.read<ReceitaProvider>();
                      final existe = receitaProvider.receitas.any(
                        (rec) =>
                            rec.nome.toLowerCase() == nomeAtual.toLowerCase(),
                      );

                      if (existe) {
                        setState(() {
                          _mensagemErro =
                              'A receita "$nomeAtual" já está cadastrada.';
                          _isSaving = false;
                        });
                        return;
                      }
                    }
                    await widget.onSalvar(
                      nomeAtual,
                      int.parse(_rendimentoController.text.trim()),
                      _imagemSelecionada,
                    );

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _mensagemErro = 'Erro ao salvar: ${e.toString()}';
                      });
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
