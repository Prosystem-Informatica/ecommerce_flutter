import 'model/finish_cart_model.dart';

abstract class IFinishCartRepository {
  Future<String> incluirPedido();
  Future<bool> gravaPed1(FinishCartModel pedido);
  Future<bool> gravaPed2(String numPed, List<FinishCartProdutoModel> produtos);
  Future<bool> confirmaPedido(String numPed);
  Future<bool> enviarPedido(FinishCartModel pedido);
}
