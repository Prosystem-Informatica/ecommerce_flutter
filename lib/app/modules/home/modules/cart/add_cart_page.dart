import 'package:ecommerce/app/core/ui/helpers/messages.dart';
import 'package:ecommerce/app/modules/home/modules/cart/cubit/order_bloc_cubit.dart';
import 'package:ecommerce/app/modules/home/modules/cart/cubit/order_bloc_state.dart';
import 'package:ecommerce/app/repositories/order/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with Messages<ProductListPage> {
  List<ProductModel> products = [
    ProductModel(
      codigo: "4303",
      produto: "ABRAÇADEIRA NYLON 2,5 X 140MM  BRANCA FERTAK",
      preco: "116,00",
      estoque: "0,00",
      imagem: "assets/no-image.jpeg",
    ),
    ProductModel(
      codigo: "3854",
      produto: "ABRAÇADEIRA NYLON 2,5X100 BR 100 UN  PRISMATEC",
      preco: "3,90",
      estoque: "91,00",
      imagem: "assets/no-image.jpeg",
    ),
    ProductModel(
      codigo: "3855",
      produto: "ABRAÇADEIRA NYLON 2,5X100 PT 100 UN  PRISMATEC",
      preco: "3,90",
      estoque: "61,00",
      imagem: "assets/no-image.jpeg",
    ),
  ];

  List<ProductModel> cart = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isGridView = false;

  double get total => cart.fold(0.0, (sum, item) {
    final precoStr = (item.preco ?? '0.0').replaceAll(',', '.');
    return sum + double.parse(precoStr);
  });

  List<ProductModel> get filteredProducts {
    if (searchQuery.isEmpty) return products;
    return products.where((product) {
      return product.produto!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          product.codigo!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<OrderBlocCubit>(context).checkUrl();
  }

  void addToCart(ProductModel product) {
    setState(() {
      cart.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo pedido')),
      body: BlocConsumer<OrderBlocCubit, OrderBlocState>(
        listener: (context, state) {
          state.status.matchAny(
            success: () async {
              //products = state.productModel ?? [];
              //showSuccess("Login efetuado com sucesso");
            },
            error: () {
              showError(state.errorMessage ?? "Erro não informado");
            },
            any: () {},
          );
          // TODO: implement listener
        },
        builder: (context, state) {
          if (state.status == OrderStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // Campo de busca + ícone de visualização
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar produtos...',
                          border: OutlineInputBorder(),
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
                      icon: Icon(
                        isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () {
                        setState(() {
                          isGridView = !isGridView;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children:
                      isGridView
                          ? filteredProducts
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 130,
                                        height: 150,
                                        child: Image.asset(
                                          "assets/no-image.jpeg",
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.codigo ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              p.produto ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'QTD: ${p.estoque ?? '0.0'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'R\$${p.preco ?? '0.0'}',
                                                  style: TextStyle(
                                                    color: Colors.green[800],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.add_shopping_cart,
                                                ),
                                                onPressed: () {
                                                  addToCart(p);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList()
                          : filteredProducts
                              .map(
                                (product) => ListTile(
                                  leading: Image.asset(
                                    product.imagem ?? 'assets/no-image.jpeg',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(product.produto ?? ''),
                                  subtitle: Text("R\$ ${product.preco}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () => addToCart(product),
                                  ),
                                ),
                              )
                              .toList(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        color: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Produtos',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cart.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                print('Próximo clicado');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Próximo'),
            ),
          ],
        ),
      ),
    );
  }
}
