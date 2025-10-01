import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/order/model/order_model.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_cubit.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_state.dart';

class OrdersWaitPage extends StatefulWidget {
  const OrdersWaitPage({super.key});

  @override
  State<OrdersWaitPage> createState() => _OrdersWaitPageState();
}

class _OrdersWaitPageState extends State<OrdersWaitPage> {
  String searchQuery = '';

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
                    if (orders.length == 1 &&
                        (orders[0].pedido ?? '').isEmpty) {
                      orders = [];
                    }

                    final filteredOrders = getFilteredOrders(orders);

                    if (filteredOrders.isEmpty) {
                      return const Center(
                        child: Text('Nenhum pedido encontrado'),
                      );
                    }

                    return ListView.separated(
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
                            child: ListTileOrdersWidget(
                              order: {
                                'number': order.pedido,
                                'client': order.cliente,
                                'total': order.total,
                                'date': order.data,
                              },
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
