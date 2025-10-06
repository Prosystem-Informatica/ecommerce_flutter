import 'package:http/http.dart' as http;
import 'model/cart_model.dart';
import 'model/cart_order_model.dart';

class FinishCartRepository {
  final String baseUrl =
      "http://prosystem04.dyndns-work.com/datasnap/rest/TServerAPPecf";

  Future<String> incluirPedido() async {
    final url = Uri.parse("$baseUrl/IncluirPedido");
    print(">>> IncluirPedido URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final numPed = response.body.replaceAll('"', '');
      print("<<< IncluirPedido Response: $numPed");
      return numPed;
    } else {
      throw Exception("Erro IncluirPedido: ${response.statusCode}");
    }
  }

  Future<void> gravaPed1(CartModel pedido, String numPed) async {
    final descontoStr = pedido.valDesc.isEmpty ? "0" : pedido.valDesc;

    final obs = pedido.obsPed.isEmpty
        ? "-"
        : Uri.encodeComponent(pedido.obsPed);

    final total = pedido.totalPed.isEmpty ? "0,00" : pedido.totalPed;

    final url = Uri.parse(
      "$baseUrl/GravaPed1/"
          "${pedido.idEmpresa}/$numPed/${pedido.idVendedor}/${pedido.idCliente}/"
          "${pedido.idTpPag}/${pedido.idCondPag}/$descontoStr/$obs/$total",
    );

    print(">>> GravaPed1 URL: $url");

    final response = await http.get(url);

    print("<<< GravaPed1 Status: ${response.statusCode}");
    print("<<< GravaPed1 Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Erro GravaPed1: ${response.statusCode}");
    }
  }

  Future<void> gravaPed2(String numPed, CartOrderModel produto) async {
    final precoStr = produto.preco.isEmpty ? "0,00" : produto.preco;

    final url = Uri.parse(
      "$baseUrl/GravaPed2/$numPed/${produto.idProduto}/${produto.quantidade}/$precoStr",
    );

    print(">>> GravaPed2 URL: $url");

    final response = await http.get(url);

    print("<<< GravaPed2 Status: ${response.statusCode}");
    print("<<< GravaPed2 Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Erro GravaPed2: ${response.statusCode}");
    }
  }

  Future<bool> enviarPedido(CartModel pedido) async {
    try {
      final numPed = await incluirPedido();

      await gravaPed1(pedido, numPed);

      for (final item in pedido.produtos) {
        await gravaPed2(numPed, item);
      }

      final urlConfirma = Uri.parse("$baseUrl/ConfirmaPed/$numPed");
      print(">>> ConfirmaPed URL: $urlConfirma");

      final response = await http.get(urlConfirma);

      print("<<< ConfirmaPed Status: ${response.statusCode}");
      print("<<< ConfirmaPed Body: ${response.body}");

      if (response.statusCode == 200) {
        final confirmado = response.body.replaceAll('"', '').toUpperCase();
        print("<<< ConfirmaPed Response: $confirmado");
        return confirmado == 'T';
      } else {
        throw Exception("Erro ConfirmaPed: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao enviar pedido: $e");
      return false;
    }
  }
}
