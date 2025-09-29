import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/payment_model.dart';

class PaymentRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';

  Future<List<CondicaoPagamentoModel>> getCondicoesPagamento() async {
    final url = Uri.parse('$baseUrl/RetornaCondPagto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = response.body.trim();

      if (body.startsWith('[') && body.endsWith(']')) {
        final List<dynamic> data = json.decode(body);
        return data.map((json) => CondicaoPagamentoModel.fromJson(json)).toList();
      } else {
        throw Exception('Resposta inesperada ao carregar condições de pagamento: $body');
      }
    } else {
      throw Exception('Erro ao carregar condições de pagamento: ${response.statusCode}');
    }
  }

  Future<List<TipoPagamentoModel>> getTiposPagamento() async {
    final url = Uri.parse('$baseUrl/RetornaTipoPagto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TipoPagamentoModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar tipos de pagamento: ${response.statusCode}');
    }
  }
}
