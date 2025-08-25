import 'package:ecommerce/app/core/ui/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/ui/widget/list_tile_orders_widget.dart';

class OrdersFinishPage extends StatefulWidget {
  const OrdersFinishPage({super.key});

  @override
  State<OrdersFinishPage> createState() => _OrdersFinishPageState();
}

class _OrdersFinishPageState extends State<OrdersFinishPage> {
  final List<Map<String, String>> orders = [
    {
      'number': '31349',
      'total': 'R\$65,44',
      'date': '12/05/2025',
      'client': 'SILVA MELO COMERCIO DE FERRAGENS LTDA ME',
    },
    {
      'number': '31295',
      'total': 'R\$936,37',
      'date': '08/05/2025',
      'client': 'EDUARDO DE J R.O. G.B FONSECA ME',
    },
    {
      'number': '30707',
      'total': 'R\$1037,7',
      'date': '02/04/2025',
      'client': 'V F DE PAULA JUNIOR',
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
            Text("CONCLUIDOS",
                style: TextStyle(color: AppColors.success, fontSize: 12)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          Divider(height: 0, color: colorScheme.outline),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(),
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