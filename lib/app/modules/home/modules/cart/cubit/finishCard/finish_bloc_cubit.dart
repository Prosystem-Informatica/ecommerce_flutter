import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../repositories/customer/customer_repository.dart';
import '../../../../../../repositories/customer/model/customer_model.dart';
import '../../../../../../repositories/payment/model/payment_model.dart';
import '../../../../../../repositories/payment/payment_repository.dart';
import '../../../../../../repositories/product/model/consult_product_model.dart';
import 'finish_bloc_state.dart';

class FinishCartCubit extends Cubit<FinishCartState> {
  final PaymentRepository paymentRepository;
  final SharedPreferences prefs;
  final CustomerRepository customerRepository;

  FinishCartCubit({
    required this.paymentRepository,
    required this.prefs,
    required this.customerRepository,
  }) : super(FinishCartState.initial()) {
    _init();
  }

  void _init() {
    final login = prefs.getString('userLogin') ?? '';
    emit(state.copyWith(vendedorLogin: login));
  }

  void setCliente(CustomerModel cliente) {
    emit(state.copyWith(cliente: cliente));
  }

  void setCondicaoPagamento(PaymentModel pagamento) {
    emit(state.copyWith(condicaoPagamento: pagamento));
  }

  void setTipoPagamento(PaymentModel pagamento) {
    emit(state.copyWith(tipoPagamento: pagamento));
  }

  void setObservacao(String obs) {
    emit(state.copyWith(obs: obs));
  }

  void setProdutos(List<ConsultProductModel> itens) {
    final novoTotal = itens.fold<double>(
      0,
          (sum, p) => sum + (double.tryParse(p.preco.replaceAll(',', '.')) ?? 0) * p.quantidade,
    );

    emit(state.copyWith(produtos: itens, total: novoTotal));
  }

  void addProduto(ConsultProductModel produto) {
    final index = state.produtos.indexWhere((p) => p.codigo == produto.codigo);
    final novaLista = List<ConsultProductModel>.from(state.produtos);

    if (index >= 0) {
      novaLista[index].quantidade += produto.quantidade > 0 ? produto.quantidade : 1;
    } else {
      produto.quantidade = produto.quantidade > 0 ? produto.quantidade : 1;
      novaLista.add(produto);
    }

    final novoTotal = novaLista.fold<double>(
      0,
          (sum, item) => sum + (double.tryParse(item.preco.replaceAll(',', '.')) ?? 0) * item.quantidade,
    );

    emit(state.copyWith(produtos: novaLista, total: novoTotal));
  }

  Future<List<PaymentModel>> fetchCondicoesPagamento() async {
    return await paymentRepository.getCondicoesPagamento();
  }

  Future<List<PaymentModel>> fetchTiposPagamento() async {
    return await paymentRepository.getTiposPagamento();
  }

  void resetarCampos() {
    emit(FinishCartState.initial().copyWith(vendedorLogin: state.vendedorLogin));
  }

  void loadInitialData(String vendedorLogin) {
    emit(state.copyWith(
      vendedorLogin: vendedorLogin,
      status: FinishCartStatus.initial,
    ));
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
}
