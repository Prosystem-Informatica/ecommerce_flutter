import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_cubit.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_state.dart';
import 'cubit/finishCard/finish_bloc_cubit.dart';

class CartItem {
  final ConsultProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 0});
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> with TickerProviderStateMixin {
  String searchQuery = '';
  bool isGrid = false;
  List<CartItem> cart = [];
  final GlobalKey _cartButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<FinishCartCubit>();

    cart = cubit.state.produtos.map((p) => CartItem(product: p, quantity: p.quantidade)).toList();
  }

  void addToCart(ConsultProductModel product) {
    final index = cart.indexWhere((item) => item.product.codigo == product.codigo);
    if (index >= 0) {
      setState(() => cart[index].quantity++);
    } else {
      setState(() => cart.add(CartItem(product: product, quantity: 1)));
    }
  }

  void removeFromCart(ConsultProductModel product) {
    final index = cart.indexWhere((item) => item.product.codigo == product.codigo);
    if (index >= 0) {
      setState(() {
        if (cart[index].quantity > 1) {
          cart[index].quantity--;
        } else {
          cart.removeAt(index);
        }
      });
    }
  }

  void _openCartModal() async {
    final cubit = context.read<FinishCartCubit>();

    final selectedProducts = await showModalBottomSheet<List<ConsultProductModel>>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Carrinho",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context, <ConsultProductModel>[]),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(child: Text('Carrinho vazio'))
                        : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (_, index) {
                        final item = cart[index];
                        return ListTile(
                          leading: Image.network(
                            item.product.imagem,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Image.asset('assets/no-image.jpeg'),
                          ),
                          title: Text(item.product.produto),
                          subtitle: Text(
                              "Qtd: ${item.quantity} • R\$ ${item.product.preco}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  removeFromCart(item.product);
                                  setModalState(() {});
                                },
                              ),
                              Text('${item.quantity}',
                                  style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  addToCart(item.product);
                                  setModalState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final productsToAdd = cart.map((e) {
                          e.product.quantidade = e.quantity;
                          return e.product;
                        }).toList();

                        cubit.setProdutos(productsToAdd);
                        Navigator.pop(context, productsToAdd);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Adicionar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(150, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedProducts != null && selectedProducts.isNotEmpty) {
      Navigator.pop(context, selectedProducts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Produtos'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por código ou nome...',
                border: const OutlineInputBorder(),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => searchQuery = ''),
                )
                    : null,
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: BlocBuilder<ConsultProductBlocCubit, ConsultProductBlocState>(
              builder: (context, state) {
                if (state.status == ConsultProductStateStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ConsultProductStateStatus.error) {
                  return Center(child: Text(state.errorMessage ?? 'Erro desconhecido'));
                }

                final products = (state.products ?? [])
                    .where((p) =>
                p.produto.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    p.codigo.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                if (products.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado'));
                }

                if (isGrid) {
                  return GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () => addToCart(product),
                        child: Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  product.imagem,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Image.asset('assets/no-image.jpeg'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(product.produto,
                                        textAlign: TextAlign.center),
                                    Text("R\$ ${product.preco} • Estoque: ${product.estoque}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      onTap: () => addToCart(product),
                      leading: Image.network(
                        product.imagem,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/no-image.jpeg'),
                      ),
                      title: Text(product.produto),
                      subtitle: Text(
                          "Código: ${product.codigo} • R\$ ${product.preco} • Estoque: ${product.estoque}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30),
        child: ElevatedButton.icon(
          key: _cartButtonKey,
          onPressed: _openCartModal,
          icon: const Icon(Icons.shopping_cart),
          label: const Text("Carrinho"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
