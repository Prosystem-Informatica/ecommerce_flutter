import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/dao/cart/product_dao.dart';
import 'i_consult_product_repository.dart';
import 'model/consult_product_model.dart';
import 'model/consult_price_model.dart';

class ConsultProductRepository implements IConsultProductRepository {
  final String baseUrl = 'http://prosystem04.dyndns-work.com:8080/datasnap/rest/TServerAPPecf';
  final String imageBaseUrl = 'http://prosystem04.dyndns-work.com/Fotos';
  final dao = ConsultProductDao();

  @override
  Future<List<ConsultProductModel>> getProducts([int? tabela]) async {
    final prefs = await SharedPreferences.getInstance();
    final tabelaSelecionada = tabela ?? prefs.getInt('tabelaPreco') ?? 2;

    final url = Uri.parse('$baseUrl/PesquisaProd//$tabelaSelecionada');

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

  @override
  Future<ConsultPriceModel?> getProductPrices(String codigo) async {
    final url = Uri.parse('$baseUrl/ConsultaProduto/$codigo');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          return ConsultPriceModel.fromJson(data.first);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
