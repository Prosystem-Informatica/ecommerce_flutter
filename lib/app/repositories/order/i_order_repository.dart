
import 'package:ecommerce/app/repositories/order/model/product_model.dart';

abstract class IOrderRepository {
  Future<List<ProductModel>> getProducts();
}
