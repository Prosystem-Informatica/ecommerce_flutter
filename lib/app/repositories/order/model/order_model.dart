class OrderModel {
  final String codigo;
  final String descricao;

  OrderModel({
    this.codigo = '',
    this.descricao = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      codigo: json['CODIGO']?.toString() ?? '',
      descricao: json['DESCR']?.toString() ?? '',
    );
  }

  static List<OrderModel> fromJsonList(dynamic data) {
    if (data is List) {
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [
      OrderModel(
        codigo: '99999',
        descricao: 'Pedido de Teste',
      ),
      OrderModel(
        codigo: '99999',
        descricao: 'Pedido de Teste',
      ),
    ];
  }

  @override
  String toString() => 'OrderModel(codigo: $codigo, descricao: $descricao)';
}
