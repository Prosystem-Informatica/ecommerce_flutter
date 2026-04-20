class ComandaItemModel {
  final String id;
  final String data;
  final String comanda;
  final String mesa;
  final String produto;
  final double prcUnit;
  final double quant;
  final double total;
  final String obsProduto;

  const ComandaItemModel({
    this.id = '',
    this.data = '',
    this.comanda = '',
    this.mesa = '',
    this.produto = '',
    this.prcUnit = 0,
    this.quant = 0,
    this.total = 0,
    this.obsProduto = '',
  });

  factory ComandaItemModel.fromJson(Map<String, dynamic> json) {
    return ComandaItemModel(
      id: json['id']?.toString() ?? '',
      data: json['data']?.toString() ?? '',
      comanda: json['comanda']?.toString() ?? '',
      mesa: json['mesa']?.toString() ?? '',
      produto: json['produto']?.toString() ?? '',
      prcUnit: (json['prcunit'] as num?)?.toDouble() ?? 0,
      quant: (json['quant'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      obsProduto: json['obsproduto']?.toString() ?? '',
    );
  }

  static List<ComandaItemModel> fromJsonList(dynamic data) {
    if (data is List) {
      return data.map((e) => ComandaItemModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  String toString() =>
      'ComandaItemModel(id: $id, produto: $produto, quant: $quant, prcUnit: $prcUnit, total: $total)';
}
