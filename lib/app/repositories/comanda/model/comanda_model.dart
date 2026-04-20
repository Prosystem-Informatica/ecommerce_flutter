class ComandaModel {
  final String data;
  final String numero; // campo "comanda" no JSON
  final double total;

  const ComandaModel({
    this.data = '',
    this.numero = '',
    this.total = 0,
  });

  factory ComandaModel.fromJson(Map<String, dynamic> json) {
    final totalRaw = json['total']?.toString() ?? '0';
    return ComandaModel(
      data: json['data']?.toString() ?? '',
      numero: json['comanda']?.toString() ?? '',
      total: double.tryParse(totalRaw.replaceAll(',', '.')) ?? 0,
    );
  }

  static List<ComandaModel> fromJsonList(dynamic data) {
    if (data is List) {
      return data.map((e) => ComandaModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  String toString() =>
      'ComandaModel(numero: $numero, data: $data, total: $total)';
}
