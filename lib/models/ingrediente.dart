class Ingrediente {
  final int? id;
  final String nome;
  final String? imagem;

  Ingrediente({this.id, required this.nome, this.imagem});

  String get urlCompleta {
    if (imagem != null && imagem!.isNotEmpty) {
      return "https://romantic-appreciation-production-6580.up.railway.app/uploads/$imagem";
    }
    return "https://via.placeholder.com/150?text=Sem+Imagem";
  }

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    return Ingrediente(
      id: json['id'],
      nome: json['nome'] ?? 'Ingrediente sem nome',
      imagem: json['imagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'imagem': imagem};
  }
}
