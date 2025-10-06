import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/dao/cart/cart_dao.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/finishCard/model/cart_model.dart';
import '../../../home/modules/cart/cubit/finishCard/finish_bloc_cubit.dart';

class LocalOrdersPage extends StatefulWidget {
  const LocalOrdersPage({super.key});

  @override
  State<LocalOrdersPage> createState() => _LocalOrdersPageState();
}

class _LocalOrdersPageState extends State<LocalOrdersPage> {
  String searchQuery = '';
  List<CartModel> localOrders = [];

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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinishCartCubit>();
    final filteredOrders = getFilteredOrders(localOrders);

    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos Locais")),
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
                child: filteredOrders.isEmpty
                    ? const Center(child: Text('Nenhum pedido salvo'))
                    : ListView.separated(
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];

                    return Card(
                      color: Colors.lightBlue[50],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTileOrdersWidget(
                              order: {
                                'number': order.numPed,
                                'client': order.idCliente,
                                'total': order.totalPed,
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final sucesso = await cubit
                                          .finishCartRepository
                                          .enviarPedido(order);
                                      if (sucesso) {
                                        final dao = CartDao();
                                        await dao.deleteCart(order.numPed);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Pedido enviado e removido do local!',
                                            ),
                                          ),
                                        );
                                        _loadLocalOrders();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Falha ao enviar pedido'),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Enviar"),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final dao = CartDao();
                                      await dao.deleteCart(order.numPed);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Pedido excluído!')),
                                      );
                                      _loadLocalOrders();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Excluir"),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
