class LoginModel {
  String? codigo;
  String? validado;
  String? empresa;

  LoginModel({this.codigo, this.validado, this.empresa});

  LoginModel.fromJson(Map<String, dynamic> json) {
    codigo = json['CODIGO'];
    validado = json['VALIDADO'];
    empresa = json['EMPRESA'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CODIGO'] = this.codigo;
    data['VALIDADO'] = this.validado;
    data['EMPRESA'] = this.empresa;
    return data;
  }
}