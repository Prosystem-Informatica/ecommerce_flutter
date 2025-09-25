import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/order/model/order_model.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_cubit.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_state.dart';

class OrdersOpenPage extends StatefulWidget {
  const OrdersOpenPage({super.key});

  @override
  State<OrdersOpenPage> createState() => _OrdersOpenPageState();
}

class _OrdersOpenPageState extends State<OrdersOpenPage> {
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
    context.read<OrderBlocCubit>().getOrders(implemented: "NÃO");
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar pedido...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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
                    child: Text(state.errorMessage ?? 'Erro ao buscar pedidos'),
                  );
                }

                List<OrderModel> orders = state.orderModel ?? [];
                if (orders.length == 1 && orders[0].pedido.isEmpty) {
                  orders = [];
                }

                final filteredOrders = getFilteredOrders(orders);

                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('Nenhum pedido encontrado'));
                }

                return ListView.separated(
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: colorScheme.shadow),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return ListTileOrdersWidget(
                      order: {
                        'number': order.pedido,
                        'client': order.cliente,
                        'total': order.total,
                        'date': order.data,
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
