import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/database/dao/cart/product_dao.dart';
import 'i_consult_product_repository.dart';
import 'model/consult_product_model.dart';

class ConsultProductRepository implements IConsultProductRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com:8080/datasnap/rest/TServerAPPecf';
  final String imageBaseUrl = 'http://prosystem04.dyndns-work.com/Fotos';
  final dao = ConsultProductDao();

  @override
  Future<List<ConsultProductModel>> getProducts() async {
    final url = Uri.parse('$baseUrl/PesquisaProd//2');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final products = data.map((json) {
          final product = ConsultProductModel.fromJson(json);
          return ConsultProductModel(
            codigo: product.codigo,
            produto: product.produto,
            preco: product.preco,
            estoque: product.estoque,
            imagem: '$imageBaseUrl/${product.codigo}-PRODUTO.jpg',
            quantidade: product.quantidade,
          );
        }).toList();

        await dao.saveProducts(products);

        return products;
      } else {
        return await dao.getProducts();
      }
    } catch (e) {
      return await dao.getProducts();
    }
  }
}
