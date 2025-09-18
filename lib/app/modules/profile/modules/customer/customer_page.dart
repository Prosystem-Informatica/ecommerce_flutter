import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/customer/model/customer_model.dart';
import 'cubit/customer_bloc_cubit.dart';
import 'cubit/customer_bloc_state.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          BlocBuilder<CustomerBlocCubit, CustomerBlocState>(
            builder: (context, state) {
              if (state.status == CustomerStateStatus.success &&
                  (state.customers?.isNotEmpty ?? false)) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(state.customers!),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerBlocCubit, CustomerBlocState>(
        builder: (context, state) {
          if (state.status == CustomerStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CustomerStateStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Erro desconhecido'),
            );
          }

          final customers = state.customers ?? [];

          if (customers.isEmpty) {
            return const Center(child: Text('Nenhum cliente encontrado'));
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) =>
                CustomerTile(customer: customers[index]),
          );
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
    final results = customers.where((c) {
      return c.cliente.toLowerCase().contains(query.toLowerCase()) ||
          c.codigo.contains(query);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) =>
          CustomerTile(customer: results[index]),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = customers.where((c) {
      return c.cliente.toLowerCase().contains(query.toLowerCase()) ||
          c.codigo.contains(query);
    }).toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) =>
          CustomerTile(customer: suggestions[index]),
    );
  }
}
