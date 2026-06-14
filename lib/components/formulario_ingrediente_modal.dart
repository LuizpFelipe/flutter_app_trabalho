import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_trabalho/utils/image_utils.dart';
import 'package:provider/provider.dart';
import '../models/ingrediente.dart';
import '../providers/inteligencia_provider.dart';
import '../providers/ingrediente_provider.dart';
import '../utils/ui_helper.dart';

class FormularioIngredienteModal extends StatefulWidget {
  final Ingrediente? ingrediente;
  final Future<void> Function(String nome, File? imagem) onSalvar;

  const FormularioIngredienteModal({
    super.key,
    this.ingrediente,
    required this.onSalvar,
  });

  @override
  State<FormularioIngredienteModal> createState() =>
      _FormularioIngredienteModalState();
}

class _FormularioIngredienteModalState
    extends State<FormularioIngredienteModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late String _nomeOriginal;

  File? _imagemSelecionada;
  bool _isSaving = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _nomeOriginal = widget.ingrediente?.nome ?? '';
    _nomeController = TextEditingController(text: _nomeOriginal);
  }

  @override
  void dispose() {
    _nomeController.dispose();
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
      title: Text(
        widget.ingrediente == null ? 'Novo Ingrediente' : 'Editar Ingrediente',
      ),
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
                      : (widget.ingrediente?.imagem != null
                            ? NetworkImage(widget.ingrediente!.urlCompleta)
                                  as ImageProvider
                            : null),
                  child:
                      _imagemSelecionada == null &&
                          widget.ingrediente?.imagem == null
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
                decoration: const InputDecoration(
                  labelText: 'Nome do Ingrediente',
                ),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Campo obrigatório' : null,
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
                      final inteligenciaProvider = context
                          .read<InteligenciaProvider>();
                      final sugestao = await inteligenciaProvider
                          .normalizarNome(nomeAtual);

                      if (sugestao != null && context.mounted) {
                        bool aceitou = await UIHelper.confirmarCorrecao(
                          context,
                          sugestao,
                        );
                        if (aceitou) nomeAtual = sugestao;
                      }
                    }
                    if (nomeAtual.toLowerCase() !=
                            _nomeOriginal.toLowerCase() &&
                        context.mounted) {
                      final ingredientesProvider = context
                          .read<IngredienteProvider>();
                      final existe = ingredientesProvider.ingredientes.any(
                        (ing) =>
                            ing.nome.toLowerCase() == nomeAtual.toLowerCase(),
                      );
                      if (existe) {
                        setState(() {
                          _mensagemErro =
                              'O ingrediente "$nomeAtual" já está cadastrado.';
                          _isSaving = false;
                        });
                        return;
                      }
                    }
                    await widget.onSalvar(nomeAtual, _imagemSelecionada);

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
