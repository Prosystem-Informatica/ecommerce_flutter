import 'cart_order_model.dart';

class CartModel {
  final String idEmpresa;
  final String numPed;
  final String idVendedor;
  final String idCliente;
  final String idTpPag;
  final String idCondPag;
  final String valDesc;
  final String obsPed;
  final String totalPed;
  final String dataPed;
  final List<CartOrderModel> produtos;

  CartModel({
    required this.idEmpresa,
    required this.numPed,
    required this.idVendedor,
    required this.idCliente,
    required this.idTpPag,
    required this.idCondPag,
    required this.valDesc,
    required this.obsPed,
    required this.totalPed,
    required this.produtos,
    this.dataPed = '',
  });

  CartModel copyWith({
    String? idEmpresa,
    String? numPed,
    String? idVendedor,
    String? idCliente,
    String? idTpPag,
    String? idCondPag,
    String? valDesc,
    String? obsPed,
    String? totalPed,
    String? dataPed,
    List<CartOrderModel>? produtos,
  }) {
    return CartModel(
      idEmpresa: idEmpresa ?? this.idEmpresa,
      numPed: numPed ?? this.numPed,
      idVendedor: idVendedor ?? this.idVendedor,
      idCliente: idCliente ?? this.idCliente,
      idTpPag: idTpPag ?? this.idTpPag,
      idCondPag: idCondPag ?? this.idCondPag,
      valDesc: valDesc ?? this.valDesc,
      obsPed: obsPed ?? this.obsPed,
      totalPed: totalPed ?? this.totalPed,
      dataPed: dataPed ?? this.dataPed,
      produtos: produtos ?? this.produtos,
    );
  }
}
