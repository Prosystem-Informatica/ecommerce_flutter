class FinishCartProdutoModel {
  final String idProduto;
  final int quantidade;
  final String preco;

  FinishCartProdutoModel({
    required this.idProduto,
    required this.quantidade,
    required this.preco,
  });

  FinishCartProdutoModel copyWith({
    String? idProduto,
    int? quantidade,
    String? preco,
  }) {
    return FinishCartProdutoModel(
      idProduto: idProduto ?? this.idProduto,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
    );
  }
}

class FinishCartModel {
  final String idEmpresa;
  final String numPed;
  final String idVendedor;
  final String idCliente;
  final String idTpPag;
  final String idCondPag;
  final String valDesc;
  final String obsPed;
  final String totalPed;
  final List<FinishCartProdutoModel> produtos;

  FinishCartModel({
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
  });

  FinishCartModel copyWith({
    String? idEmpresa,
    String? numPed,
    String? idVendedor,
    String? idCliente,
    String? idTpPag,
    String? idCondPag,
    String? valDesc,
    String? obsPed,
    String? totalPed,
    List<FinishCartProdutoModel>? produtos,
  }) {
    return FinishCartModel(
      idEmpresa: idEmpresa ?? this.idEmpresa,
      numPed: numPed ?? this.numPed,
      idVendedor: idVendedor ?? this.idVendedor,
      idCliente: idCliente ?? this.idCliente,
      idTpPag: idTpPag ?? this.idTpPag,
      idCondPag: idCondPag ?? this.idCondPag,
      valDesc: valDesc ?? this.valDesc,
      obsPed: obsPed ?? this.obsPed,
      totalPed: totalPed ?? this.totalPed,
      produtos: produtos ?? this.produtos,
    );
  }
}
