import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/database/dao/cart/cart_dao.dart';
import '../../../../../../repositories/customer/customer_repository.dart';
import '../../../../../../repositories/customer/model/customer_model.dart';
import '../../../../../../repositories/finishCard/finish_card_repository.dart';
import '../../../../../../repositories/finishCard/model/cart_model.dart';
import '../../../../../../repositories/finishCard/model/cart_order_model.dart';
import '../../../../../../repositories/payment/model/payment_model.dart';
import '../../../../../../repositories/payment/payment_repository.dart';
import '../../../../../../repositories/product/model/consult_product_model.dart';
import 'finish_bloc_state.dart';

class FinishCartCubit extends Cubit<FinishCartState> {
  final PaymentRepository paymentRepository;
  final SharedPreferences prefs;
  final CustomerRepository customerRepository;
  final FinishCartRepository finishCartRepository;
  final CartDao _cartDao = CartDao();

  List<CustomerModel> clientesLista = [];
  List<ConsultProductModel> produtosLista = [];
  List<CondicaoPagamentoModel> condicoesPagamento = [];
  List<TipoPagamentoModel> tiposPagamento = [];

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
      final clientes = await customerRepository.getCustomers();
      clientesLista = clientes;
      return clientes;
    } catch (e) {
      final clientesOffline = await customerRepository.dao.getCustomers();
      clientesLista = clientesOffline;
      return clientesOffline;
    }
  }

  Future<List<CondicaoPagamentoModel>> fetchCondicoesPagamento() async {
    try {
      final condicoes = await paymentRepository.getCondicoesPagamento();
      condicoesPagamento = condicoes;
      return condicoes;
    } catch (e) {
      final condicoesOffline = await paymentRepository.dao.getCondicoesPagamento();
      condicoesPagamento = condicoesOffline;
      return condicoesOffline;
    }
  }

  Future<List<TipoPagamentoModel>> fetchTiposPagamento() async {
    try {
      final tipos = await paymentRepository.getTiposPagamento();
      tiposPagamento = tipos;
      return tipos;
    } catch (e) {
      final tiposOffline = await paymentRepository.dao.getTiposPagamento();
      tiposPagamento = tiposOffline;
      return tiposOffline;
    }
  }

  Future<List<CartModel>> fetchPedidosPendentes() async {
    try {
      return await _cartDao.getCarts();
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: "Erro ao buscar pedidos: $e",
      ));
      return [];
    }
  }


  Future<void> salvarLocalmente(double desconto) async {
    final pedido = _montarPedido(desconto);

    try {
      await _cartDao.saveCart(pedido);
      emit(state.copyWith(
        status: FinishCartStatus.success,
        successMessage: "Pedido salvo localmente!",
      ));
      resetarCampos();
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: "Erro ao salvar localmente: $e",
      ));
    }
  }

  Future<bool> enviarTodosPedidos() async {
    final pedidos = await fetchPedidosPendentes();
    if (pedidos.isEmpty) return false;

    bool todosEnviados = true;
    emit(state.copyWith(status: FinishCartStatus.loading));

    for (final pedido in pedidos) {
      final sucesso = await finishCartRepository.enviarPedido(pedido);
      if (!sucesso) {
        todosEnviados = false;
        break;
      } else {
        await _cartDao.deleteCart(pedido.numPed);
      }
    }

    emit(state.copyWith(status: FinishCartStatus.initial));
    return todosEnviados;
  }

  Future<void> atualizarPedidoLocal(CartModel pedidoAtualizado) async {
    try {
      await _cartDao.deleteCart(pedidoAtualizado.numPed);
      await _cartDao.saveCart(pedidoAtualizado);
      emit(state.copyWith(
        status: FinishCartStatus.success,
        successMessage: "Pedido atualizado com sucesso!",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: "Erro ao atualizar pedido: $e",
      ));
    }
  }

  void limparMensagens() {
    emit(state.copyWith(
      successMessage: '',
      errorMessage: '',
      status: FinishCartStatus.initial,
    ));
  }

  Future<void> excluirPedidoLocal(String numPed) async {
    try {
      await _cartDao.deleteCart(numPed);
      emit(state.copyWith(
        status: FinishCartStatus.success,
        successMessage: "Pedido excluído com sucesso!",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FinishCartStatus.error,
        errorMessage: "Erro ao excluir pedido: $e",
      ));
    }
  }

  String _formatarValor(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  String _gerarNumeroPedido() => DateTime.now().millisecondsSinceEpoch.toString();

  CartModel _montarPedido(double desconto) {
    final totalComDesconto = state.total - desconto;

    return CartModel(
      idEmpresa: state.empresaId,
      numPed: _gerarNumeroPedido(),
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

  CartOrderModel _converterProduto(ConsultProductModel p) {
    final precoDouble = double.tryParse(p.preco.replaceAll(',', '.')) ?? 0;
    return CartOrderModel(
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
