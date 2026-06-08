class Receita {
  final int? id;
  final String nome;
  final int rendimentoPadrao;
  final String? imagem;

  Receita({
    this.id,
    required this.nome,
    required this.rendimentoPadrao,
    this.imagem,
  });

  String get urlCompleta {
    if (imagem != null && imagem!.isNotEmpty) {
      return "http://192.168.1.92:8000/static/$imagem";
    }
    return "https://via.placeholder.com/150?text=Sem+Foto";
  }

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'],
      nome: json['nome'] ?? 'Sem nome',
      rendimentoPadrao: (json['rendimento_padrao'] as num? ?? 1).toInt(),
      imagem: json['imagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'rendimento_padrao': rendimentoPadrao,
      'imagem': imagem,
    };
  }
}
