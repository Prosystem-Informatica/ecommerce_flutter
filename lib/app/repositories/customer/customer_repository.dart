import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/database/dao/cart/custummer_dao.dart';
import 'i_customer_repository.dart';
import 'model/customer_model.dart';

class CustomerRepository implements ICustomerRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';
  final dao = CustomerDao();

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final url = Uri.parse('$baseUrl/pesquisaCliente/');


    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final customers = data.map((json) => CustomerModel.fromJson(json)).toList();

        await dao.saveCustomers(customers);

        return customers;
      } else {
        return await dao.getCustomers();
      }
    } catch (e) {
      return await dao.getCustomers();
    }
  }
}
