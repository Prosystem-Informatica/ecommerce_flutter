import 'package:bloc/bloc.dart';
import 'package:ecommerce/app/repositories/order/order_repository.dart';

import 'order_bloc_state.dart';

class OrderBlocCubit extends Cubit<OrderBlocState> {
  final OrderRepository orderRepository;
  OrderBlocCubit({required this.orderRepository})
      : super(OrderBlocState.initial());

  Future<void> checkUrl() async {
    try {
      emit(
        state.copyWith(
          status: OrderStateStatus.loading,
        ),
      );
      final products = await orderRepository.getProducts();

      print("Oq temos aq ${products.toString()}");

      emit(
        state.copyWith(
          status: OrderStateStatus.success,
          productModel: products,
        ),
      );

    } on Exception {
      emit(
        state.copyWith(
          status: OrderStateStatus.error,
          errorMessage: "Erro ao efetuar Login",
        ),
      );
    }
  }

}
