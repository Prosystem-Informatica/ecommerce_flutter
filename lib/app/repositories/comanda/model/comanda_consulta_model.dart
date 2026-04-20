import 'comanda_item_model.dart';

class ComandaConsultaModel {
  final double totalComanda;
  final List<ComandaItemModel> dados;

  const ComandaConsultaModel({
    required this.totalComanda,
    required this.dados,
  });

  factory ComandaConsultaModel.fromJson(Map<String, dynamic> json) {
    final dadosList = json['dados'];
    return ComandaConsultaModel(
      totalComanda: (json['totalcomanda'] as num?)?.toDouble() ?? 0,
      dados: dadosList is List
          ? dadosList.map((e) => ComandaItemModel.fromJson(e)).toList()
          : [],
    );
  }

  @override
  String toString() =>
      'ComandaConsultaModel(totalComanda: $totalComanda, itens: ${dados.length})';
}
