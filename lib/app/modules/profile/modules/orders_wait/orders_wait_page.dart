import 'package:flutter/material.dart';

import '../../../../core/ui/widget/list_tile_orders_widget.dart';

class OrdersWaitPage extends StatefulWidget {
  const OrdersWaitPage({super.key});

  @override
  State<OrdersWaitPage> createState() => _OrdersWaitPageState();
}

class _OrdersWaitPageState extends State<OrdersWaitPage> {
  final List<Map<String, String>> orders = [
    {
      'number': '31353',
      'total': 'R\$22,25',
      'date': '26/05/2025',
      'client': 'CLIENTE TESTE',
    },
    {
      'number': '31324',
      'total': 'R\$70,29',
      'date': '09/05/2025',
      'client': 'DEPOSITO NOSSA CASA TATINHO',
    },
    {
      'number': '30594',
      'total': 'R\$0,01',
      'date': '27/03/2025',
      'client': 'WANDERLEY FLORES FERRAGENS ME',
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
