import 'model/payment_model.dart';

abstract class IPaymentRepository {
  Future<List<PaymentModel>> getCondicoesPagamento();
  Future<List<PaymentModel>> getTiposPagamento();
}
