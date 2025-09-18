class CustomerModel {
  final String codigo;
  final String cliente;

  CustomerModel({
    required this.codigo,
    required this.cliente,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      codigo: json['CODIGO']?.toString() ?? '',
      cliente: json['CLIENTE']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CODIGO': codigo,
      'CLIENTE': cliente,
    };
  }
}
