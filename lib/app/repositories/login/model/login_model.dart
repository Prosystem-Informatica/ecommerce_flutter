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

  LoginModel.fromJson(Map<String, dynamic> json) {
    codigo = json['CODIGO'];
    validado = json['VALIDADO'];
    empresa = json['EMPRESA'];
    frete = json['FRETE'];
    valKm = json['VALKM'];
    valMinKm = json['VALMINKM'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['CODIGO'] = codigo;
    data['VALIDADO'] = validado;
    data['EMPRESA'] = empresa;
    data['FRETE'] = frete;
    data['VALKM'] = valKm;
    data['VALMINKM'] = valMinKm;
    return data;
  }
}
