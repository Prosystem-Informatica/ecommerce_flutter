import 'comanda_model.dart';

class ComandaListaModel {
  final double totalGeral;
  final List<ComandaModel> dados;

  const ComandaListaModel({
    required this.totalGeral,
    required this.dados,
  });

  factory ComandaListaModel.fromJson(Map<String, dynamic> json) {
    final totalMap = json['total'];
    final totalRaw = (totalMap is Map ? totalMap['totalGeral'] : null)
            ?.toString() ??
        '0';
    final comandasList = json['comandas'];
    return ComandaListaModel(
      totalGeral: double.tryParse(totalRaw.replaceAll(',', '.')) ?? 0,
      dados: comandasList is List
          ? comandasList.map((e) => ComandaModel.fromJson(e)).toList()
          : [],
    );
  }

  @override
  String toString() =>
      'ComandaListaModel(totalGeral: $totalGeral, comandas: ${dados.length})';
}
