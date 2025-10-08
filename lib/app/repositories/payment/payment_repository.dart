import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/database/dao/cart/payment_dao.dart';
import 'model/payment_model.dart';

class PaymentRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';
  final dao = PaymentDao();

  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
    final url = Uri.parse('$baseUrl/RetornaTipoPagto');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tipos = data.map((json) => TipoPagamentoModel.fromJson(json)).toList();

        await dao.saveTiposPagamento(tipos);
        return tipos;
      } else {
        return await dao.getTiposPagamento();
      }
    } catch (e) {
      return await dao.getTiposPagamento();
    }
  }

  Future<List<CondicaoPagamentoModel>> getCondicoesPagamento() async {
    final url = Uri.parse('$baseUrl/RetornaCondPagto');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = response.body.trim();

        if (body.startsWith('[') && body.endsWith(']')) {
          final List<dynamic> data = json.decode(body);
          final condicoes = data.map((json) => CondicaoPagamentoModel.fromJson(json)).toList();

          await dao.saveCondicoesPagamento(condicoes);
          return condicoes;
        } else {
          throw Exception('Resposta inesperada: $body');
        }
      } else {
        return await dao.getCondicoesPagamento();
      }
    } catch (e) {
      return await dao.getCondicoesPagamento();
    }
  }
}
