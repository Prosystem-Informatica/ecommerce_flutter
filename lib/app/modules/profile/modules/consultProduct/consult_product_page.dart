import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import 'cubit/consult_product_bloc_cubit.dart';
import 'cubit/consult_product_bloc_state.dart';

class ConsultProductPage extends StatefulWidget {
  const ConsultProductPage({super.key});

  @override
  State<ConsultProductPage> createState() => _ConsultProductPageState();
}

class _ConsultProductPageState extends State<ConsultProductPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Consultar Produtos'),
      ),
      body: Column(
        children: [
          // Campo de busca + botão de alternar grid/list
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar produtos...',
                      border: const OutlineInputBorder(),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchQuery = '';
                          });
                        },
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                ),
              ],
            ),
          ),

          // Lista ou grid de produtos
          Expanded(
            child: BlocBuilder<ConsultProductBlocCubit, ConsultProductBlocState>(
              builder: (context, state) {
                if (state.status == ConsultProductStateStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ConsultProductStateStatus.error) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Erro desconhecido'),
                  );
                }

                // Filtro por nome ou código
                final filteredProducts = (state.products ?? []).where((p) {
                  return p.produto.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      p.codigo.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado'));
                }

                if (isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                      );
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        isGrid: false,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ConsultProductModel product;
  final bool isGrid;

  const ProductCard({
    super.key,
    required this.product,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return isGrid
        ? Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.imagem,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/no-image.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.produto,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'R\$ ${product.preco} • Estoque: ${product.estoque}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    )
        : ListTile(
      leading: Image.network(
        product.imagem,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/no-image.jpeg',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(product.produto),
      subtitle: Text(
        'Código: ${product.codigo} • R\$ ${product.preco} • Estoque: ${product.estoque}',
      ),
    );
  }
}
