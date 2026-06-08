import 'ingrediente.dart';

class ReceitaIngrediente {
  final int? id;
  final int receitaId;
  final int ingredienteId;
  final double quantidade;
  final String unidade;

  final Ingrediente? ingrediente;

  ReceitaIngrediente({
    this.id,
    required this.receitaId,
    required this.ingredienteId,
    required this.quantidade,
    required this.unidade,
    this.ingrediente,
  });

  factory ReceitaIngrediente.fromJson(Map<String, dynamic> json) {
    return ReceitaIngrediente(
      id: json['id'],
      receitaId: json['receita_id'],
      ingredienteId: json['ingrediente_id'],
      quantidade: (json['quantidade'] as num).toDouble(),
      unidade: json['unidade'] ?? 'un',
      ingrediente: json['ingrediente'] != null
          ? Ingrediente.fromJson(json['ingrediente'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receita_id': receitaId,
      'ingrediente_id': ingredienteId,
      'quantidade': quantidade,
      'unidade': unidade,
    };
  }
}
