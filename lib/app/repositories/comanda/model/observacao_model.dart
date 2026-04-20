class ObservacaoModel {
  final String codigo;
  final String descricao;

  const ObservacaoModel({
    this.codigo = '',
    this.descricao = '',
  });

  // TODO: ajustar as chaves conforme retorno real do back-end
  factory ObservacaoModel.fromJson(Map<String, dynamic> json) {
    return ObservacaoModel(
      codigo: json['CODIGO']?.toString() ??
          json['codigo']?.toString() ??
          '',
      descricao: json['DESCRICAO']?.toString() ??
          json['descricao']?.toString() ??
          '',
    );
  }

  static List<ObservacaoModel> fromJsonList(dynamic data) {
    if (data is List) {
      return data.map((e) => ObservacaoModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  String toString() => 'ObservacaoModel($codigo: $descricao)';
}
