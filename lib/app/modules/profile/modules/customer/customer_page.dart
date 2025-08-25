import 'package:flutter/material.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final List<Map<String, String>> customers = [
    {'name': 'CONSUMIDOR', 'code': '1'},
    {'name': 'A F TUAN LTDA', 'code': '441'},
    {'name': 'A.A.SANTOS TUAN MAT CONSTRUÇÃO ME', 'code': '69'},
    {'name': 'A.C DA SILVA MATERIAIS PARA COSNTRUÇAO', 'code': '312'},
    {'name': 'A.C.ALVES LAJES ME', 'code': '124'},
    {'name': 'ADILSON FREITAS DO PRADO CAMPOS DO JORDÃO ME', 'code': '177'},
    {'name': 'ADRIANA CRISTINA DE LIMA', 'code': '402'},
    {'name': 'ADRIANO AUGUSTO OLIVEIRA', 'code': '421'},
    {'name': 'ADRINO MARK G DA SILVA INTALÇOES', 'code': '316'},
    {'name': 'AGROVALE COMERCIAL DE RAÇOES LTDA ME', 'code': '330'},
    {'name': 'AIRTON DE SOUSA 63910810187', 'code': '175'},
    {'name': 'AISLAN VENDEDOR', 'code': '122'},
    {'name': 'AKS COMERCIO DE MATERIAIS ELETRICOS LTDA ME', 'code': '234'},
    {'name': 'ALAIDES FERREIRA GOMES 30614124840', 'code': '106'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implementar busca
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Código: ${customer['code']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (index != customers.length - 1) Divider(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}