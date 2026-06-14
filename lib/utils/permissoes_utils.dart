import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissoesUtils {
  static Future<bool> verificarGaleria(BuildContext context) async {
    return true;
  }

  static Future<bool> verificarCamera(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _mostrarAlertaConfiguracao(context, "Câmera");
      }
      return false;
    }

    return status.isGranted;
  }

  static void _mostrarAlertaConfiguracao(BuildContext context, String recurso) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("Permissão de $recurso Necessária"),
        content: Text(
          "O aplicativo precisa de acesso à $recurso para permitir a inclusão de imagens. "
          "Como a permissão foi negada anteriormente, você precisa ativá-la manualmente nas configurações.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text("IR PARA CONFIGURAÇÕES"),
          ),
        ],
      ),
    );
  }
}
