import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_rpayment_repository.dart';
import 'model/payment_model.dart';


class PaymentRepository implements IPaymentRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';

  @override
  Future<List<PaymentModel>> getCondicoesPagamento() async {
    final url = Uri.parse('$baseUrl/RetornaCondPagto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar condições de pagamento: ${response.statusCode}');
    }
  }

  @override
  Future<List<PaymentModel>> getTiposPagamento() async {
    final url = Uri.parse('$baseUrl/RetornaTipoPagto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar tipos de pagamento: ${response.statusCode}');
    }
  }
}
