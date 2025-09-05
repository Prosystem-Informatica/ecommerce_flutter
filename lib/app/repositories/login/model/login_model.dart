class LoginModel {
  String? codigo;
  String? validado;
  String? empresa;
  String? frete;
  String? valKm;
  String? valMinKm;

  LoginModel({
    this.codigo,
    this.validado,
    this.empresa,
    this.frete,
    this.valKm,
    this.valMinKm,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      codigo: json['CODIGO'],
      validado: json['VALIDADO'],
      empresa: json['EMPRESA'],
      frete: json['FRETE'],
      valKm: json['VALKM'],
      valMinKm: json['VALMINKM'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'validado': validado,
      'empresa': empresa,
      'frete': frete,
      'valKm': valKm,
      'valMinKm': valMinKm,
    };
  }
}
