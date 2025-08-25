import 'package:flutter/material.dart';

import '../../../../core/ui/widget/list_tile_orders_widget.dart';

class OrdersOpenPage extends StatefulWidget {
  const OrdersOpenPage({super.key});

  @override
  State<OrdersOpenPage> createState() => _OrdersOpenPageState();
}

class _OrdersOpenPageState extends State<OrdersOpenPage> {
  final List<Map<String, String>> orders = [
    {
      'number': '31350',
      'total': 'R\$384,89',
      'date': '12/05/2025',
      'client': 'FERRAGENS MATTEY LTDA ME',
    },
    {
      'number': '31325',
      'total': 'R\$61,81',
      'date': '09/05/2025',
      'client': 'DEL REY FERRAGENS II LTDA',
    },
    {
      'number': '31049',
      'total': 'R\$21,93',
      'date': '24/04/2025',
      'client': 'CONSUMIDOR',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      /*appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: BackButton(color: colorScheme.onPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pedidos", style: TextStyle(color: colorScheme.onPrimary)),
            Text("EM ABERTO",
                style: TextStyle(color: colorScheme.error, fontSize: 12)),
          ],
        ),
      ),*/
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar pedido...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => Divider(color: colorScheme.shadow,),
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTileOrdersWidget(order: order);
              },
            ),
          ),
        ],
      ),
    );
  }
}