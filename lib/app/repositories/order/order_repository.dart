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
      var host = prefs.getString("host");
      var port = prefs.getString("port");

      print("Host > $host");
      print("Port > $port");

      final url = '/datasnap/rest/TServerAPPecf/PesquisaProd/';
      final response = await _rest.get(url);
      print("RES DATA > ${response.data}");

      final data = response.data;

      if (data is List) {
        return ProductModel.fromJsonList(data);
      } else {
        return [];
      }
    } catch (e) {
      log(e.toString());
      return [ProductModel()];
    }
  }

  Future<List<OrderModel>> getOrders({String implemented = "NÃO"}) async {
    try {
      prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString('userCodigo') ?? '';
      final companyCode = prefs.getString('companyCodigo') ?? '';

      if (userCode.isEmpty || companyCode.isEmpty) {
        log("Códigos do usuário ou empresa não encontrados");
        return [];
      }

      final url =
          '/datasnap/rest/TServerAPPecf/RetornaSitPedido/$userCode/$companyCode/$implemented';
      final response = await _rest.get(url);

      print("Pedidos [$implemented] > ${response.data}");

      final data = response.data;

      if (data is List &&
          data.isNotEmpty &&
          (data[0]['PEDIDO'] == null ||
              data[0]['PEDIDO'].toString().isEmpty)) {
        return [];
      }

      return OrderModel.fromJsonList(data);
    } catch (e) {
      log("Erro em getOrders: $e");
      return [];
    }
  }

  Future<List<OrderModel>> getImplementedOrders() async {
    return getOrders(implemented: "SIM");
  }

  Future<List<OrderModel>> getNotImplementedOrders() async {
    return getOrders(implemented: "NÃO");
  }
}
