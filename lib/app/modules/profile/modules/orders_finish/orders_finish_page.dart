import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/ui/widget/list_tile_orders_widget.dart';
import '../../../../repositories/order/model/order_model.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_cubit.dart';
import '../../../home/modules/cart/cubit/order/order_bloc_state.dart';

class OrdersFinishPage extends StatefulWidget {
  const OrdersFinishPage({super.key});

  @override
  State<OrdersFinishPage> createState() => _OrdersFinishPageState();
}

class _OrdersFinishPageState extends State<OrdersFinishPage> {
  String searchQuery = '';
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

    context.read<OrderBlocCubit>().getOrders(implemented: "SIM");
  }

  List<OrderModel> getFilteredOrders(List<OrderModel> orders) {
    List<OrderModel> filtered = orders;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((o) {
        final cliente = (o.cliente ?? '').toLowerCase();
        final pedido = (o.pedido ?? '').toLowerCase();
        return cliente.contains(searchQuery.toLowerCase()) ||
            pedido.contains(searchQuery.toLowerCase());
      }).toList();
    }

    filtered = filtered.where((o) {
      if (o.data == null || o.data.isEmpty) return false;
      try {
        final parsedDate = DateFormat("dd/MM/yyyy").parse(o.data);
        final matchesMonth = parsedDate.month == selectedMonth;
        final matchesYear = parsedDate.year == selectedYear;
        return matchesMonth && matchesYear;
      } catch (e) {
        return false;
      }
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - i);

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/bg-login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar pedido...',
                    hintStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                  style: TextStyle(color:Colors.black),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedMonth,
                        decoration: InputDecoration(
                          labelText: "Mês",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(color:Colors.black),
                        dropdownColor: Colors.white,
                        items: List.generate(12, (i) {
                          final month = i + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              DateFormat.MMMM('pt_BR')
                                  .format(DateTime(0, month))
                                  .toUpperCase(),
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }),
                        onChanged: (val) {
                          setState(() {
                            selectedMonth = val!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: InputDecoration(
                          labelText: "Ano",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                        items: years
                            .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(
                            y.toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedYear = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

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
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    List<OrderModel> orders = state.orderModel ?? [];
                    if (orders.length == 1 && (orders[0].pedido ?? '').isEmpty) {
                      orders = [];
                    }

                    final filteredOrders = getFilteredOrders(orders);

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhum pedido encontrado',
                          style: TextStyle(color: primaryColor),
                        ),
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
