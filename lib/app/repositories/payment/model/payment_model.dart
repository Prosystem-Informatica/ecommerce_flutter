class PaymentModel {
  final String codigo;
  final String descricao;

  PaymentModel({
    required this.codigo,
    required this.descricao,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      codigo: json['CODIGO']?.toString() ?? '',
      descricao: json['FORMAPAGTO']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CODIGO': codigo,
      'FORMAPAGTO': descricao,
    };
  }
}
