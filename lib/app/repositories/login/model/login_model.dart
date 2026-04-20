class LoginModel {
  String? codigo;
  String? validado;
  String? empresa;
  String? restaurante;
  String? frete;
  String? valKm;
  String? valMinKm;
  String? fantasia;
  String? email;
  String? imagem64;

  bool get isRestaurante => restaurante?.toUpperCase() == 'SIM';

  LoginModel({
    this.codigo,
    this.validado,
    this.empresa,
    this.restaurante,
    this.frete,
    this.valKm,
    this.valMinKm,
    this.fantasia,
    this.email,
    this.imagem64,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      codigo: json['CODIGO'],
      validado: json['VALIDADO'],
      empresa: json['EMPRESA'],
      restaurante: json['RESTAURANTE'],
      frete: json['FRETE'],
      valKm: json['VALKM'],
      valMinKm: json['VALMINKM'],
      fantasia: json['FANTASIA'],
      email: json['EMAIL'],
      imagem64: json['IMAGEM64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'validado': validado,
      'empresa': empresa,
      'restaurante': restaurante,
      'frete': frete,
      'valKm': valKm,
      'valMinKm': valMinKm,
      'fantasia': fantasia,
      'email': email,
      'imagem64': imagem64,
    };
  }
}
