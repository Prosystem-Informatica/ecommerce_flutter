import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/order/model/order_model.dart';
import '../../../../repositories/order/order_repository.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_cubit.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_state.dart';

class OrdersOpenPage extends StatefulWidget {
  const OrdersOpenPage({super.key});

  @override
  State<OrdersOpenPage> createState() => _OrdersOpenPageState();
}

class _OrdersOpenPageState extends State<OrdersOpenPage> {
  String searchQuery = '';
  bool _modalAberto = false;

  List<OrderModel> getFilteredOrders(List<OrderModel> orders) {
    if (searchQuery.isEmpty) return orders;
    return orders.where((o) {
      final cliente = o.cliente.toLowerCase();
      final pedido = o.pedido.toLowerCase();
      return cliente.contains(searchQuery.toLowerCase()) ||
          pedido.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    context.read<OrderBlocCubit>().getOrders(implemented: "NAO");
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                      borderSide: BorderSide(color: primaryColor, width: 2),
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
                child: BlocBuilder<OrderBlocCubit, OrderBlocState>(
                  builder: (context, state) {
                    if (state.status == OrderStateStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == OrderStateStatus.error) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Erro ao buscar pedidos',
                        ),
                      );
                    }

                    List<OrderModel> orders = state.orderModel ?? [];
                    if (orders.isEmpty ||
                        (orders.length == 1 &&
                            (orders[0].pedido ?? '').isEmpty)) {
                      return const Center(
                        child: Text('Nenhum pedido encontrado'),
                      );
                    }

                    final filteredOrders = getFilteredOrders(orders);

                    if (filteredOrders.isEmpty) {
                      return const Center(
                        child: Text('Nenhum pedido encontrado'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Card(
                            color: Colors.lightBlue[50],
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (_modalAberto) return;
                                setState(() {
                                  _modalAberto = true;
                                });

                                final repo =
                                context
                                    .read<OrderBlocCubit>()
                                    .orderRepository
                                as OrderRepository;

                                final details = await repo.getOrderDetails(
                                  pedido: order.pedido,
                                  implemented: false,
                                );

                                if (details.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Nenhum item encontrado"),
                                    ),
                                  );
                                  setState(() {
                                    _modalAberto = false;
                                  });
                                  return;
                                }

                                final condicao = details.first.condicao;
                                final forma = details.first.forma;

                                double totalItens = 0;
                                for (var item in details) {
                                  totalItens +=
                                      double.tryParse(item.total.replaceAll(',', '.')) ?? 0;
                                }

                                final desconto = double.tryParse(order.desconto.replaceAll(',', '.')) ?? 0;
                                final totalComDesconto = totalItens - desconto;

                                String formatar(double valor) =>
                                    valor.toStringAsFixed(2).replaceAll('.', ',');

                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (ctx) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(ctx).viewInsets.bottom,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        height:
                                        MediaQuery.of(ctx).size.height * 0.65,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Pedido #${order.pedido}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  icon: const Icon(Icons.close),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Cliente: ${order.cliente}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "Condição de Pagamento: $condicao",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "Forma: $forma",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Desconto: R\$ ${formatar(desconto)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                              child: ListView.separated(
                                                itemCount: details.length,
                                                separatorBuilder:
                                                    (_, __) => const Divider(height: 1),
                                                itemBuilder: (context, i) {
                                                  final item = details[i];
                                                  return Padding(
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "${item.produto} (COD: ${item.codProd})",
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          "Qtd: ${item.quant} - Unit: R\$ ${item.prcUnit}",
                                                        ),
                                                        Text(
                                                          "Total: R\$ ${item.total}",
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                setState(() {
                                  _modalAberto = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTileOrdersWidget(
                                  order: {
                                    'number': order.pedido,
                                    'client': order.cliente,
                                    'total': order.total,
                                    'date': order.data,
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
