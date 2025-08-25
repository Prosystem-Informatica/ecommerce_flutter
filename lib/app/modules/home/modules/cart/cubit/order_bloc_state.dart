import 'package:ecommerce/app/repositories/order/model/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:match/match.dart';

part 'order_bloc_state.g.dart';

@match
enum OrderStateStatus { initial, loading, error, success }

class OrderBlocState extends Equatable {
  final List<ProductModel>? productModel;
  final OrderStateStatus status;
  final String? errorMessage;
  final String? successMessage;

  const OrderBlocState({
    required this.productModel,
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  OrderBlocState.initial()
      : status = OrderStateStatus.initial,
        productModel = [ProductModel()],
        errorMessage = null,
        successMessage = null;

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    successMessage
  ];

  OrderBlocState copyWith({
    //ValidationModel? validationModel,
    List<ProductModel>? productModel,
    OrderStateStatus? status,
    String? errorMessage,
    String? successMessage
  }) {
    return OrderBlocState(
      //validationModel: validationModel ?? this.validationModel,
        productModel: productModel ?? this.productModel,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        successMessage: successMessage ?? this.successMessage
    );
  }
}
