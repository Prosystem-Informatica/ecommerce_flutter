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
  final CondicaoPagamentoModel? condicaoPagamento;
  final TipoPagamentoModel? tipoPagamento;
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
    CondicaoPagamentoModel? condicaoPagamento,
    TipoPagamentoModel? tipoPagamento,
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
      total: total ?? _calculaTotal(produtos ?? this.produtos),
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double _calculaTotal(List<ConsultProductModel> produtos) {
    return produtos.fold<double>(
      0.0,
          (sum, p) =>
      sum + (double.tryParse(p.preco.replaceAll(',', '.')) ?? 0) * p.quantidade,
    );
  }

  List<Map<String, dynamic>> get produtosAgrupados {
    final Map<String, ConsultProductModel> agrupados = {};
    for (var p in produtos) {
      if (agrupados.containsKey(p.codigo)) {
        agrupados[p.codigo]!.quantidade += p.quantidade;
      } else {
        agrupados[p.codigo] = ConsultProductModel(
          codigo: p.codigo,
          produto: p.produto,
          preco: p.preco,
          estoque: p.estoque,
          imagem: p.imagem,
          quantidade: p.quantidade,
        );
      }
    }
    return agrupados.values
        .map((p) => {
      'ID_PROD': p.codigo,
      'QtdProd': p.quantidade,
      'PrcUnit': p.preco,
    })
        .toList();
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
