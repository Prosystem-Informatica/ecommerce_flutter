import 'package:ecommerce/app/repositories/finishCard/model/cart_model.dart';
import 'package:ecommerce/app/repositories/finishCard/model/cart_order_model.dart';

abstract class IFinishCartRepository {
  Future<String> incluirPedido();
  Future<void> gravaPed1(CartModel pedido, String numPed);
  Future<void> gravaPed2(String numPed, CartOrderModel produto);
  Future<bool> enviarPedido(CartModel pedido);
}
