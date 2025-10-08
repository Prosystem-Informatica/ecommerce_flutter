import 'package:sqflite/sqflite.dart';
import '../../../../repositories/payment/model/payment_model.dart';
import '../../database.dart';

class PaymentDao {
  static const String _tableTipoPagamento = 'tipo_pagamento';

  static const String createTablePaymentType = '''
    CREATE TABLE $_tableTipoPagamento (
      codigo TEXT PRIMARY KEY,
      descricao TEXT
    );
  ''';

  Future<int> saveTipoPagamento(TipoPagamentoModel tipoPagamento) async {
    final Database db = await getDatabase();
    return await db.insert(
      _tableTipoPagamento,
      _toMapTipoPagamento(tipoPagamento),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      _tableTipoPagamento,
    );

    return result
        .map(
          (map) => TipoPagamentoModel(
            codigo: map['codigo'],
            descricao: map['descricao'],
          ),
        )
        .toList();
  }

  Future<TipoPagamentoModel?> getTipoPagamentoByCode(String codigo) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      _tableTipoPagamento,
      where: 'codigo = ?',
      whereArgs: [codigo],
    );

    if (result.isNotEmpty) {
      final tipoPagamento =
          result
              .map(
                (map) => TipoPagamentoModel(
                  codigo: map['codigo'].toString(),
                  descricao: map['descricao'].toString(),
                ),
              )
              .first;

      return tipoPagamento;
    }
    return null;
  }

  Future<int> deleteTipoPagamento(String codigo) async {
    final Database db = await getDatabase();
    return await db.delete(
      _tableTipoPagamento,
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
  }

  Map<String, dynamic> _toMapTipoPagamento(TipoPagamentoModel tipoPagamento) {
    return {
      'codigo': tipoPagamento.codigo,
      'descricao': tipoPagamento.descricao,
    };
  }
}
