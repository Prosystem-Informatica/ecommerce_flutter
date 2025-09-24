import 'package:flutter/material.dart';

class FinishCartPage extends StatefulWidget {
  const FinishCartPage({super.key});

  @override
  State<FinishCartPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<FinishCartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Pedido")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextField(decoration: InputDecoration(labelText: "Cliente")),
            TextField(decoration: InputDecoration(labelText: "Vendedor")),
            TextField(decoration: InputDecoration(labelText: "Observações")),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Produtos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("+ Adicionar"),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text("Produto Exemplo"),
                subtitle: const Text("Qtd: 2  |  Preço: 50,00"),
                trailing: const Text("Total: 100,00"),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "prazo", child: Text("A Prazo")),
                DropdownMenuItem(value: "avista", child: Text("À Vista")),
              ],
              onChanged: (v) {},
              decoration: const InputDecoration(labelText: "Condição de Pagamento"),
            ),

            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "dinheiro", child: Text("Dinheiro")),
                DropdownMenuItem(value: "cartao", child: Text("Cartão")),
              ],
              onChanged: (v) {},
              decoration: const InputDecoration(labelText: "Forma de Pagamento"),
            ),

            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Descontos:"), Text("R\$ 0,00")]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Acréscimos:"), Text("R\$ 0,00")]),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Pedido", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("R\$ 0,00", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white
                    ),
                    child: const Text("Gravar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}