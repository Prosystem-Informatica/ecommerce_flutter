import 'model/cart_model.dart';
import 'model/cart_order_model.dart';

abstract class IFinishCartRepository {
  Future<String> incluirPedido();
  Future<bool> gravaPed1(CartModel pedido);
  Future<bool> gravaPed2(String numPed, List<CartOrderModel> produtos);
  Future<bool> confirmaPedido(String numPed);
  Future<bool> enviarPedido(CartModel pedido);
}
