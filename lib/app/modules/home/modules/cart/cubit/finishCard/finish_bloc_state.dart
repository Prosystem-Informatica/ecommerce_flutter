import 'package:equatable/equatable.dart';
import 'package:match/match.dart';
import '../../../../../../repositories/customer/model/customer_model.dart';
import '../../../../../../repositories/payment/model/payment_model.dart';
import '../../../../../../repositories/product/model/consult_product_model.dart';

part 'finish_bloc_state.g.dart';

@match
enum FinishCartStatus { initial, loading, error, success }

class FinishCartState extends Equatable {
  final List<ConsultProductModel> produtos;
  final CustomerModel? cliente;
  final PaymentModel? condicaoPagamento;
  final PaymentModel? tipoPagamento;
  final String obs;
  final String vendedorLogin;
  final double total;
  final FinishCartStatus status;
  final String? errorMessage;

  const FinishCartState({
    required this.produtos,
    this.cliente,
    this.condicaoPagamento,
    this.tipoPagamento,
    this.obs = '',
    this.vendedorLogin = '',
    this.total = 0.0,
    this.status = FinishCartStatus.initial,
    this.errorMessage,
  });

  factory FinishCartState.initial() {
    return const FinishCartState(
      produtos: [],
      cliente: null,
      condicaoPagamento: null,
      tipoPagamento: null,
      obs: '',
      vendedorLogin: '',
      total: 0.0,
      status: FinishCartStatus.initial,
      errorMessage: null,
    );
  }

  FinishCartState copyWith({
    List<ConsultProductModel>? produtos,
    CustomerModel? cliente,
    PaymentModel? condicaoPagamento,
    PaymentModel? tipoPagamento,
    String? obs,
    String? vendedorLogin,
    double? total,
    FinishCartStatus? status,
    String? errorMessage,
  }) {
    return FinishCartState(
      produtos: produtos ?? this.produtos,
      cliente: cliente ?? this.cliente,
      condicaoPagamento: condicaoPagamento ?? this.condicaoPagamento,
      tipoPagamento: tipoPagamento ?? this.tipoPagamento,
      obs: obs ?? this.obs,
      vendedorLogin: vendedorLogin ?? this.vendedorLogin,
      total: total ?? this.total,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    produtos,
    cliente,
    condicaoPagamento,
    tipoPagamento,
    obs,
    vendedorLogin,
    total,
    status,
    errorMessage,
  ];
}
