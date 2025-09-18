import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_customer_repository.dart';
import 'model/customer_model.dart';

class CustomerRepository implements ICustomerRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final url = Uri.parse('$baseUrl/pesquisaCliente/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar clientes: ${response.statusCode}');
    }
  }
}
