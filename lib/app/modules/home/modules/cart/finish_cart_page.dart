import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ui/helpers/messages.dart';
import '../../../../repositories/customer/model/customer_model.dart';
import '../../../../repositories/payment/model/payment_model.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import '../../../../repositories/finishCard/model/cart_model.dart';
import '../../../profile/modules/orders_wait/orders_local_page.dart';
import '../comanda/cubit/comanda_cubit.dart';
import 'cubit/finishCard/finish_bloc_cubit.dart';
import 'cubit/finishCard/finish_bloc_state.dart';
import 'add_cart_page.dart';

class FinishCartPage extends StatefulWidget {
  final CartModel? pedido;

  const FinishCartPage({super.key, this.pedido});

  @override
  State<FinishCartPage> createState() => _FinishCartPageState();
}

class _FinishCartPageState extends State<FinishCartPage>
    with Messages<FinishCartPage> {
  final TextEditingController _descontoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _numComandaCtrl = TextEditingController();
  final TextEditingController _numMesaCtrl = TextEditingController();

  bool _isRestaurante = false;

  late final FinishCartCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<FinishCartCubit>();

    _observacaoController.text = widget.pedido?.obsPed ?? '';
    _descontoController.text = widget.pedido?.valDesc ?? '0,00';

    if (widget.pedido != null) {
      _reconstruirPedido(widget.pedido!);
    }

    _loadRestauranteFlag();
  }

  Future<void> _loadRestauranteFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final flag = prefs.getString('isRestaurante') ?? 'NAO';
    if (mounted) {
      setState(() => _isRestaurante = flag.toUpperCase() == 'SIM');
    }
  }

  @override
  void dispose() {
    _descontoController.dispose();
    _observacaoController.dispose();
    _numComandaCtrl.dispose();
    _numMesaCtrl.dispose();
    super.dispose();
  }

  Future<void> _reconstruirPedido(CartModel pedido) async {
    await Future.wait([
      cubit.fetchProdutosLocais(),
      cubit.fetchClientes(),
      cubit.fetchTiposPagamento(),
      cubit.fetchCondicoesPagamento(),
    ]);

    final cliente = cubit.clientesLista.firstWhere(
      (c) => c.codigo == pedido.idCliente,
      orElse:
          () => CustomerModel(
            codigo: '',
            cliente: '',
            endereco: '',
            bairro: '',
            cidade: '',
            uf: '',
            restricao: '',
            limiteCredito: '',
          ),
    );
    cubit.setCliente(cliente);

    final tipo = cubit.tiposPagamento.firstWhere(
      (t) => t.codigo == pedido.idTpPag,
      orElse: () => TipoPagamentoModel(codigo: '', descricao: ''),
    );
    cubit.setTipoPagamento(tipo);

    final cond = cubit.condicoesPagamento.firstWhere(
      (c) => c.codigo == pedido.idCondPag,
      orElse: () => CondicaoPagamentoModel(codigo: '', descricao: ''),
    );
    cubit.setCondicaoPagamento(cond);

    List<ConsultProductModel> produtosReconstruidos = [];
    if (cubit.produtosLista.isNotEmpty) {
      produtosReconstruidos =
          pedido.produtos.map((p) {
            final local = cubit.produtosLista.firstWhere(
              (prod) => prod.codigo == p.idProduto,
              orElse:
                  () => ConsultProductModel(
                    codigo: p.idProduto,
                    produto: 'Produto #${p.idProduto}',
                    preco: p.preco,
                    estoque: '0',
                    imagem: '',
                    quantidade: p.quantidade,
                  ),
            );
            return local.copyWith(
              quantidade: p.quantidade,
              preco: p.preco,
            );
          }).toList();
    } else {
      produtosReconstruidos =
          pedido.produtos.map((p) {
            return ConsultProductModel(
              codigo: p.idProduto,
              produto: 'Produto #${p.idProduto}',
              preco: p.preco,
              estoque: '0',
              imagem: '',
              quantidade: p.quantidade,
            );
          }).toList();
    }

    cubit.setProdutos(produtosReconstruidos);
    cubit.setObservacao(pedido.obsPed);
    _descontoController.text = pedido.valDesc ?? '0,00';
  }

  bool validateFields(FinishCartState state) {
    if (state.cliente == null) {
      showError("Selecione um cliente.");
      return false;
    }
    if (state.produtos.isEmpty) {
      showError("Adicione pelo menos um produto.");
      return false;
    }
    if (state.condicaoPagamento == null) {
      showError("Selecione a condição de pagamento.");
      return false;
    }
    if (state.tipoPagamento == null) {
      showError("Selecione o tipo de pagamento.");
      return false;
    }

    final desconto =
        double.tryParse(_descontoController.text.replaceAll(',', '.')) ?? 0.0;
    if (desconto >= state.total) {
      showError("O desconto não pode ser maior ou igual ao total do pedido.");
      return false;
    }
    return true;
  }

  double calcularTotalComDesconto(FinishCartState state) {
    final desconto =
        double.tryParse(_descontoController.text.replaceAll(',', '.')) ?? 0.0;
    final total = state.total - desconto;
    return total >= 0 ? total : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Pedido")),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
          ),
          BlocConsumer<FinishCartCubit, FinishCartState>(
            listener: (context, state) {
              state.status.matchAny(
                success: () {
                  showSuccess(
                    state.successMessage ?? "Pedido salvo com sucesso!",
                  );
                  cubit.resetarCampos();
                  _descontoController.clear();
                  _observacaoController.clear();
                  LocalOrdersPage.updateNotifier.value =
                      !LocalOrdersPage.updateNotifier.value;
                  Navigator.pop(context);
                },
                error: () {
                  showError(state.errorMessage ?? "Erro ao salvar pedido.");
                },
                any: () {},
              );
            },
            builder: (context, state) {
              final totalComDesconto = calcularTotalComDesconto(state);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Campos exclusivos do modo Restaurante ───────────────
                    if (_isRestaurante) ...[
                      TextField(
                        controller: _numComandaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Comanda *',
                          hintText: 'Número da comanda',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _numMesaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mesa',
                          hintText: 'Número da mesa (opcional)',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Campos exclusivos do modo Ecommerce ─────────────────
                    if (!_isRestaurante) ...[
                      GestureDetector(
                        onTap: () async {
                          final clientes = await cubit.fetchClientes();
                          if (!mounted) return;
                          if (clientes.isEmpty) {
                            showError("Nenhum cliente encontrado.");
                            return;
                          }
                          _showSearch<CustomerModel>(
                            context: context,
                            title: "Selecione o Cliente",
                            items: clientes,
                            display: (c) => c.cliente,
                            onSelected: cubit.setCliente,
                          );
                        },
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: "Cliente"),
                          child: Text(state.cliente?.cliente ?? "Selecionar"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _observacaoController,
                        decoration:
                            const InputDecoration(labelText: "Observações"),
                        onChanged: cubit.setObservacao,
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Produtos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final result =
                                await Navigator.push<List<ConsultProductModel>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductListPage(
                                      isRestaurante: _isRestaurante,
                                    ),
                                  ),
                                );
                            if (result != null) {
                              cubit.setProdutos(result);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[50],
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text("+ Adicionar"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    state.produtos.isEmpty
                        ? const Text("Nenhum produto adicionado.")
                        : SizedBox(
                          height: 250,
                          child: ListView.builder(
                            itemCount: state.produtos.length,
                            itemBuilder: (_, index) {
                              final p = state.produtos[index];
                              return Card(
                                color: Colors.lightBlue[50],
                                child: ListTile(
                                  title: Text(p.produto),
                                  subtitle: Text(
                                    "Qtd: ${p.quantidade} • Preço: R\$ ${p.preco.replaceAll(',', '.')}",
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        cubit.state.produtos.removeAt(index);
                                      });
                                      cubit.setProdutos(
                                        List.from(cubit.state.produtos),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    // ── Pagamento/desconto — apenas ecommerce ───────────────
                    if (!_isRestaurante) ...[
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          final condicoes =
                              await cubit.fetchCondicoesPagamento();
                          if (!mounted) return;
                          _showSearch<CondicaoPagamentoModel>(
                            context: context,
                            title: "Selecione a Condição de Pagamento",
                            items: condicoes,
                            display: (p) => p.descricao ?? "",
                            onSelected: cubit.setCondicaoPagamento,
                          );
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Condição de Pagamento",
                          ),
                          child: Text(
                            state.condicaoPagamento?.descricao ?? "Selecionar",
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final tipos = await cubit.fetchTiposPagamento();
                          if (!mounted) return;
                          _showSearch<TipoPagamentoModel>(
                            context: context,
                            title: "Selecione o Tipo de Pagamento",
                            items: tipos,
                            display: (p) => p.descricao ?? "",
                            onSelected: cubit.setTipoPagamento,
                          );
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Tipo de Pagamento",
                          ),
                          child: Text(
                            state.tipoPagamento?.descricao ?? "Selecionar",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _descontoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\,?\d{0,2}'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: "Desconto",
                          prefixText: "R\$ ",
                        ),
                        onTap: () {
                          _descontoController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _descontoController.text.length,
                          );
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: Colors.lightBlue[50],
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Pedido",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "R\$ ${totalComDesconto.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_isRestaurante) {
                                // ── Fluxo Restaurante ─────────────────────
                                if (_numComandaCtrl.text.trim().isEmpty) {
                                  showError("Informe o número da comanda.");
                                  return;
                                }
                                if (state.produtos.isEmpty) {
                                  showError(
                                      "Adicione pelo menos um produto.");
                                  return;
                                }
                                final ok = await context
                                    .read<ComandaCubit>()
                                    .salvarComanda(
                                      numComanda:
                                          _numComandaCtrl.text.trim(),
                                      numMesa: _numMesaCtrl.text.trim(),
                                      produtos: state.produtos,
                                    );
                                if (!mounted) return;
                                if (ok) {
                                  showSuccess("Comanda salva com sucesso!");
                                  cubit.resetarCampos();
                                  _numComandaCtrl.clear();
                                  _numMesaCtrl.clear();
                                  Navigator.pop(context);
                                } else {
                                  showError("Erro ao salvar comanda.");
                                }
                              } else {
                                // ── Fluxo Ecommerce (sem alterações) ──────
                                if (!validateFields(state)) return;

                                final desconto =
                                    double.tryParse(
                                      _descontoController.text
                                          .replaceAll(',', '.'),
                                    ) ??
                                    0.0;

                                try {
                                  final pedido = await cubit
                                      .montarPedidoComDesconto(desconto);

                                  final pedidoFinal = pedido.copyWith(
                                    valDesc: desconto
                                        .toStringAsFixed(2)
                                        .replaceAll('.', ','),
                                    numPed:
                                        cubit.state.pedidoEmEdicao?.numPed ??
                                        pedido.numPed,
                                  );

                                  await cubit.salvarPedidoLocal(pedidoFinal);
                                } catch (e) {
                                  print("Erro ao salvar pedido: $e");
                                  showError("Erro ao salvar pedido.");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Enviar"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              cubit.resetarCampos();
                              _descontoController.clear();
                              _observacaoController.clear();
                              _numComandaCtrl.clear();
                              _numMesaCtrl.clear();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Cancelar"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSearch<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) display,
    required void Function(T) onSelected,
  }) async {
    if (items.isEmpty || !mounted) return;

    final searchController = TextEditingController();
    List<T> filtered = List.from(items);

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(title),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 400,
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            labelText: 'Pesquisar',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              filtered =
                                  items
                                      .where(
                                        (e) => display(e)
                                            .toLowerCase()
                                            .contains(value.toLowerCase()),
                                      )
                                      .toList();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              filtered.isEmpty
                                  ? const Center(
                                    child: Text("Nenhum item encontrado"),
                                  )
                                  : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (_, index) {
                                      final item = filtered[index];
                                      return ListTile(
                                        title: Text(display(item)),
                                        onTap: () {
                                          onSelected(item);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}

extension ConsultProductCopy on ConsultProductModel {
  ConsultProductModel copyWith({
    String? codigo,
    String? produto,
    String? preco,
    String? estoque,
    String? imagem,
    int? quantidade,
    String? obs,
  }) {
    return ConsultProductModel(
      codigo: codigo ?? this.codigo,
      produto: produto ?? this.produto,
      preco: preco ?? this.preco,
      estoque: estoque ?? this.estoque,
      imagem: imagem ?? this.imagem,
      quantidade: quantidade ?? this.quantidade,
      obs: obs ?? this.obs,
    );
  }
}
