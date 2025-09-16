import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/rest/rest_client.dart';
import 'i_order_repository.dart';
import 'model/product_model.dart';
import 'model/order_model.dart';

class OrderRepository implements IOrderRepository {
  final RestClient _rest;
  late SharedPreferences prefs;

  OrderRepository({required RestClient rest}) : _rest = rest;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      prefs = await SharedPreferences.getInstance();
      var host = await prefs.getString("host");
      var port = await prefs.getString("port");

      print("Host > ${host}");

      var url = '/datasnap/rest/TServerAPPecf/PesquisaProd/';
      var response = await _rest.get(url);
      print("RES DATA > ${response.data}");

      var jsonData = jsonDecode(response.data);
      print("Json > ${jsonData}");

      if (response.statusCode == 200) {
        print("Resposta: ${response.data}");
      } else {
        print("Erro: ${response.statusCode}");
      }

      var res = await ProductModel.fromJsonList(jsonData);

      return res;
    } catch (e) {
      log(e.toString());
      return [ProductModel()];
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString('userCodigo') ?? '';
      final companyCode = prefs.getString('companyCodigo') ?? '';

      if (userCode.isEmpty || companyCode.isEmpty) {
        log("Códigos do usuário ou empresa não encontrados no SharedPreferences");
        return [];
      }

      final url =
          '/datasnap/rest/TServerAPPecf/RetornaSitPedido/$userCode/$companyCode';

      final response = await _rest.get(url);
      print("Pedidos Situação > ${response.data}");

      final orders = OrderModel.fromJsonList(jsonDecode(response.data));
      return orders;
    } catch (e) {
      log("Erro em getOrders: $e");
      return [];
    }
  }
}
