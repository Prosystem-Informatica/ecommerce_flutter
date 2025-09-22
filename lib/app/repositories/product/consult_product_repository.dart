import 'dart:convert';
import 'package:http/http.dart' as http;
import 'i_consult_product_repository.dart';
import 'model/consult_product_model.dart';

class ConsultProductRepository implements IConsultProductRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf';
  final String imageBaseUrl = 'http://prosystem04.dyndns-work.com/FotosGimenes';

  @override
  Future<List<ConsultProductModel>> getProducts() async {
    final url = Uri.parse('$baseUrl/PesquisaProd');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((json) {
        final product = ConsultProductModel.fromJson(json);
        return ConsultProductModel(
          codigo: product.codigo,
          produto: product.produto,
          preco: product.preco,
          estoque: product.estoque,
          imagem: '$imageBaseUrl/${product.codigo}-PRODUTO.jpg',
        );
      }).toList();
    } else {
      throw Exception('Erro ao carregar produtos: ${response.statusCode}');
    }
  }
}
