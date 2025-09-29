import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../repositories/customer/customer_repository.dart';
import '../../../../../../repositories/customer/model/customer_model.dart';
import '../../../../../../repositories/finishCard/finish_card_repository.dart';
import '../../../../../../repositories/finishCard/model/finish_cart_model.dart';
import '../../../../../../repositories/payment/model/payment_model.dart';
import '../../../../../../repositories/payment/payment_repository.dart';
import '../../../../../../repositories/product/model/consult_product_model.dart';
import 'finish_bloc_state.dart';

class FinishCartCubit extends Cubit<FinishCartState> {
  final PaymentRepository paymentRepository;
  final SharedPreferences prefs;
  final CustomerRepository customerRepository;
  final FinishCartRepository finishCartRepository;

  FinishCartCubit({
    required this.paymentRepository,
    required this.prefs,
    required this.customerRepository,
    required this.finishCartRepository,
  }) : super(FinishCartState.initial()) {
    _init();
  }

  void _init() {
    final codigo = prefs.getString('userCodigo') ?? '';
    emit(state.copyWith(vendedorLogin: codigo));
  }

  void setCliente(CustomerModel cliente) {
    emit(state.copyWith(cliente: cliente));
  }

  void setCondicaoPagamento(CondicaoPagamentoModel pagamento) {
    emit(state.copyWith(condicaoPagamento: pagamento));
  }

  void setTipoPagamento(TipoPagamentoModel pagamento) {
    emit(state.copyWith(tipoPagamento: pagamento));
  }

  void setObservacao(String obs) {
    emit(state.copyWith(obs: obs));
  }

  void setProdutos(List<ConsultProductModel> itens) {
    final agrupados = _agruparProdutos(itens);
    emit(state.copyWith(produtos: agrupados));
  }

  void addProduto(ConsultProductModel produto) {
    final novaLista = List<ConsultProductModel>.from(state.produtos);
    final index = novaLista.indexWhere((p) => p.codigo == produto.codigo);

    if (index >= 0) {
      novaLista[index].quantidade += produto.quantidade > 0 ? produto.quantidade : 1;
    } else {
      produto.quantidade = produto.quantidade > 0 ? produto.quantidade : 1;
      novaLista.add(produto);
    }

    emit(state.copyWith(produtos: _agruparProdutos(novaLista)));
  }

  List<ConsultProductModel> _agruparProdutos(List<ConsultProductModel> produtos) {
    final Map<String, ConsultProductModel> map = {};

    for (var p in produtos) {
      if (map.containsKey(p.codigo)) {
        map[p.codigo]!.quantidade += p.quantidade;
      } else {
        map[p.codigo] = ConsultProductModel(
          codigo: p.codigo,
          produto: p.produto,
          preco: p.preco,
          estoque: p.estoque,
          imagem: p.imagem,
          quantidade: p.quantidade,
        );
      }
    }

    return map.values.toList();
  }

  Future<List<CondicaoPagamentoModel>> fetchCondicoesPagamento() async {
    return await paymentRepository.getCondicoesPagamento();
  }

  Future<List<TipoPagamentoModel>> fetchTiposPagamento() async {
    return await paymentRepository.getTiposPagamento();
  }

  void resetarCampos() {
    emit(FinishCartState.initial().copyWith(vendedorLogin: state.vendedorLogin));
  }

  Future<List<CustomerModel>> fetchClientes() async {
    try {
      final clientes = await customerRepository.getCustomers();
      return clientes;
    } catch (e) {
      emit(state.copyWith(status: FinishCartStatus.error, errorMessage: e.toString()));
      return [];
    }
  }

  Future<bool> enviarPedido(double desconto) async {
    emit(state.copyWith(status: FinishCartStatus.loading));

    try {
      final totalComDesconto = state.total - desconto;
      final pedido = FinishCartModel(
        idEmpresa: "1",
        numPed: "",
        idVendedor: state.vendedorLogin,
        idCliente: state.cliente?.codigo ?? "",
        idTpPag: state.tipoPagamento?.codigo ?? "",
        idCondPag: state.condicaoPagamento?.codigo ?? "",
        valDesc: desconto,
        obsPed: state.obs,
        totalPed: totalComDesconto,
        produtos: state.produtos
            .map((p) => FinishCartProdutoModel(
          idProduto: p.codigo,
          quantidade: p.quantidade,
          preco: double.tryParse(p.preco.replaceAll(',', '.')) ?? 0,
        ))
            .toList(),
      );

      final sucesso = await finishCartRepository.enviarPedido(pedido);

      if (sucesso) {
        emit(state.copyWith(status: FinishCartStatus.success));
        return true;
      } else {
        emit(state.copyWith(
            status: FinishCartStatus.error,
            errorMessage: "Falha ao enviar pedido"));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(status: FinishCartStatus.error, errorMessage: e.toString()));
      return false;
    }
  }
}
