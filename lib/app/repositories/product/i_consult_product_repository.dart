import 'model/consult_product_model.dart';

abstract class IConsultProductRepository {
  Future<List<ConsultProductModel>> getProducts();
}
