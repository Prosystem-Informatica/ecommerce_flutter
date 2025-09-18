import 'package:flutter/material.dart';
import '../../../../repositories/customer/customer_repository.dart';
import '../../../../repositories/customer/i_customer_repository.dart';
import '../../../../repositories/customer/model/customer_model.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late final ICustomerRepository repository;
  List<CustomerModel> customers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    repository = CustomerRepository();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final data = await repository.getCustomers();
      if (!mounted) return;
      setState(() {
        customers = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar clientes: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          if (!loading && customers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(customers),
                );
              },
            ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return CustomerTile(customer: customer);
                },
              ),
    );
  }
}

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  const CustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customer.cliente,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Código: ${customer.codigo}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<CustomerModel> customers;
  CustomSearchDelegate(this.customers);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        customers.where((c) {
          return c.cliente.toLowerCase().contains(query.toLowerCase()) ||
              c.codigo.contains(query);
        }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => CustomerTile(customer: results[index]),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        customers.where((c) {
          return c.cliente.toLowerCase().contains(query.toLowerCase()) ||
              c.codigo.contains(query);
        }).toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder:
          (context, index) => CustomerTile(customer: suggestions[index]),
    );
  }
}
