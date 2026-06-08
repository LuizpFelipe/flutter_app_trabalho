import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'permissoes_utils.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> selecionarImagem(BuildContext context) async {
    final temPermissao = await PermissoesUtils.verificarGaleria(context);

    if (!temPermissao) return null;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }

    return null;
  }
}
