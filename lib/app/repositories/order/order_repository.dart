import 'dart:convert';
import 'dart:developer';
import 'package:ecommerce/app/repositories/login/model/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/rest/rest_client.dart';
import 'i_order_repository.dart';
import 'model/product_model.dart';

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
      //return ValidationModel();
    }
  }
}
