import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/dao/cart/cart_dao.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/finishCard/model/cart_model.dart';
import '../../../home/modules/cart/cubit/finishCard/finish_bloc_cubit.dart';
import '../../../home/modules/cart/finish_cart_page.dart';

class LocalOrdersPage extends StatefulWidget {
  const LocalOrdersPage({super.key});

  @override
  State<LocalOrdersPage> createState() => _LocalOrdersPageState();
}

class _LocalOrdersPageState extends State<LocalOrdersPage> {
  String searchQuery = '';
  List<CartModel> localOrders = [];
  bool _modalAberto = false;

  @override
  void initState() {
    super.initState();
    _loadLocalOrders();
  }

  Future<void> _loadLocalOrders() async {
    final dao = CartDao();
    final pedidos = await dao.getCarts();
    setState(() {
      localOrders = pedidos;
    });
  }

  List<CartModel> getFilteredOrders(List<CartModel> orders) {
    if (searchQuery.isEmpty) return orders;
    return orders.where((o) {
      final cliente = o.idCliente.toLowerCase();
      final pedido = o.numPed.toLowerCase();
      return cliente.contains(searchQuery.toLowerCase()) ||
          pedido.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _abrirDetalhes(CartModel order) async {
    if (_modalAberto) return;
    _modalAberto = true;

    final cubit = context.read<FinishCartCubit>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        double total =
            double.tryParse(order.totalPed.replaceAll(',', '.')) ?? 0.0;
        double desconto =
            double.tryParse(order.valDesc.replaceAll(',', '.')) ?? 0.0;
        double totalComDesconto = total - desconto;
        String formatar(double valor) =>
            valor.toStringAsFixed(2).replaceAll('.', ',');

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(ctx).size.height * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pedido #${order.numPed}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Cliente: ${order.idCliente}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Forma de Pagamento: ${order.idTpPag}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Condição: ${order.idCondPag}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Desconto: R\$ ${formatar(desconto)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total do Pedido: R\$ ${formatar(totalComDesconto)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: order.produtos.length,
                    itemBuilder: (context, i) {
                      final item = order.produtos[i];
                      final preco =
                          double.tryParse(item.preco.replaceAll(',', '.')) ?? 0;
                      final totalItem = preco * item.quantidade;
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Produto: ${item.idProduto}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text("Qtd: ${item.quantidade}"),
                            Text("Unit: R\$ ${formatar(preco)}"),
                            Text("Total: R\$ ${formatar(totalItem)}"),
                            const Divider(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                        onPressed: () async {
                          cubit.limparMensagens();
                          Navigator.of(ctx).pop();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FinishCartPage()),
                          );
                          _loadLocalOrders();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Excluir"),
                        onPressed: () async {
                          await cubit.excluirPedidoLocal(order.numPed);
                          if ((cubit.state.successMessage ?? '').isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(cubit.state.successMessage!),
                              ),
                            );
                          }
                          cubit.limparMensagens();
                          Navigator.of(ctx).pop();
                          _loadLocalOrders();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    _modalAberto = false;
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders(localOrders);
    final cubit = context.read<FinishCartCubit>();

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar pedido...',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child:
                    filteredOrders.isEmpty
                        ? const Center(child: Text('Nenhum pedido salvo'))
                        : ListView.separated(
                          itemCount: filteredOrders.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Card(
                                color: Colors.lightBlue[50],
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _abrirDetalhes(order),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTileOrdersWidget(
                                      order: {
                                        'number': order.numPed,
                                        'client': order.idCliente,
                                        'total': order.totalPed,
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          localOrders.isEmpty
              ? null
              : Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 5.0),
                  child: FloatingActionButton(
                    onPressed: () async {
                      final enviados = await cubit.enviarTodosPedidos();
                      if (enviados) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Todos os pedidos enviados!'),
                          ),
                        );
                      }
                      cubit.limparMensagens();
                      _loadLocalOrders();
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send, color: Colors.white),
                    elevation: 3,
                  ),
                ),
              ),
    );
  }
}
