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
  }) : super(
    FinishCartState.initial().copyWith(
      vendedorLogin: prefs.getString('userCodigo') ?? '',
      empresaId: prefs.getString('companyCodigo') ?? '',
    ),
  );

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
    emit(state.copyWith(produtos: _agruparProdutos(itens)));
  }

  void addProduto(ConsultProductModel produto) {
    final novaLista = List<ConsultProductModel>.from(state.produtos);
    final index = novaLista.indexWhere((p) => p.codigo == produto.codigo);

    if (index >= 0) {
      novaLista[index].quantidade += produto.quantidadePositiva;
    } else {
      novaLista.add(produto.copiaComQuantidadePositiva);
    }

    emit(state.copyWith(produtos: _agruparProdutos(novaLista)));
  }

  void resetarCampos() {
    emit(
      FinishCartState.initial().copyWith(
        vendedorLogin: state.vendedorLogin,
        empresaId: state.empresaId,
      ),
    );
  }

  Future<List<CustomerModel>> fetchClientes() async {
    try {
      return await customerRepository.getCustomers();
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: e.toString(),
      ));
      return [];
    }
  }

  Future<List<CondicaoPagamentoModel>> fetchCondicoesPagamento() async {
    try {
      return await paymentRepository.getCondicoesPagamento();
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: e.toString(),
      ));
      return [];
    }
  }

  Future<List<TipoPagamentoModel>> fetchTiposPagamento() async {
    try {
      return await paymentRepository.getTiposPagamento();
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: e.toString(),
      ));
      return [];
    }
  }

  Future<bool> enviarPedido(double desconto) async {
    emit(state.copyWith(status: FinishCartStatus.loading));

    try {
      final pedido = _montarPedido(desconto);
      final sucesso = await finishCartRepository.enviarPedido(pedido);

      if (sucesso) {
        emit(state.copyWith(status: FinishCartStatus.success));
        return true;
      } else {
        emit(state.copyWith(
          status: FinishCartStatus.error,
          errorMessage: "Falha ao enviar pedido",
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  String _formatarValor(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  FinishCartModel _montarPedido(double desconto) {
    final totalComDesconto = state.total - desconto;

    return FinishCartModel(
      idEmpresa: state.empresaId,
      numPed: "",
      idVendedor: state.vendedorLogin,
      idCliente: state.cliente?.codigo ?? "",
      idTpPag: state.tipoPagamento?.codigo ?? "",
      idCondPag: state.condicaoPagamento?.codigo ?? "",
      valDesc: _formatarValor(desconto),
      obsPed: state.obs,
      totalPed: _formatarValor(totalComDesconto),
      produtos: state.produtos.map(_converterProduto).toList(),
    );
  }

  FinishCartProdutoModel _converterProduto(ConsultProductModel p) {
    final precoDouble = double.tryParse(p.preco.replaceAll(',', '.')) ?? 0;
    return FinishCartProdutoModel(
      idProduto: p.codigo,
      quantidade: p.quantidade,
      preco: _formatarValor(precoDouble),
    );
  }

  List<ConsultProductModel> _agruparProdutos(List<ConsultProductModel> produtos) {
    final Map<String, ConsultProductModel> map = {};
    for (var p in produtos) {
      if (map.containsKey(p.codigo)) {
        map[p.codigo]!.quantidade += p.quantidade;
      } else {
        map[p.codigo] = p;
      }
    }
    return map.values.toList();
  }
}

extension ProdutoHelpers on ConsultProductModel {
  int get quantidadePositiva => quantidade > 0 ? quantidade : 1;

  ConsultProductModel get copiaComQuantidadePositiva => ConsultProductModel(
    codigo: codigo,
    produto: produto,
    preco: preco,
    estoque: estoque,
    imagem: imagem,
    quantidade: quantidadePositiva,
  );
}
