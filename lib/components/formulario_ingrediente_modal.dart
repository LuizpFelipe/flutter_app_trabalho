import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_trabalho/utils/image_utils.dart';
import 'package:provider/provider.dart';
import '../models/ingrediente.dart';
import '../providers/inteligencia_provider.dart';
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
                  setState(() => _isSaving = true);

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

                    await widget.onSalvar(nomeAtual, _imagemSelecionada);

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao salvar: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
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
