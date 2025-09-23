import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_cubit.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_state.dart';

class CartItem {
  final ConsultProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
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

  void addToCartWithAnimation(ConsultProductModel product, BuildContext context, GlobalKey productKey) {
    final renderBox = productKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (renderBox == null || overlay == null) {
      addToCart(product);
      return;
    }

    final start = renderBox.localToGlobal(Offset.zero);
    final endBox = _cartButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (endBox == null) {
      addToCart(product);
      return;
    }
    final end = endBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(builder: (_) {
      return AnimatedFly(
        start: start,
        end: end,
        imageUrl: product.imagem,
      );
    });

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 600), () {
      overlayEntry.remove();
      addToCart(product);
    });
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

  double get total => cart.fold(0.0, (sum, item) {
    final precoStr = item.product.preco.replaceAll(',', '.');
    return sum + double.parse(precoStr) * item.quantity;
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar produtos...',
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
                  return Center(
                    child: Text(state.errorMessage ?? 'Erro desconhecido'),
                  );
                }

                final products = (state.products ?? [])
                    .where((p) => p.produto.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                if (products.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado'));
                }

                if (isGrid) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productKey = GlobalKey();
                      return GestureDetector(
                        key: productKey,
                        onTap: () => addToCartWithAnimation(product, context, productKey),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.network(
                                  product.imagem,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset('assets/no-image.jpeg'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(product.produto,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                    final productKey = GlobalKey();
                    return ListTile(
                      key: productKey,
                      onTap: () => addToCartWithAnimation(product, context, productKey),
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
                      subtitle: Text("Código: ${product.codigo} • R\$ ${product.preco} • Estoque: ${product.estoque}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                key: _cartButtonKey,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.6,
                            ),
                            padding: const EdgeInsets.all(16.0),
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
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Expanded(
                                  child: cart.isEmpty
                                      ? const Center(child: Text('Carrinho vazio'))
                                      : Scrollbar(
                                    child: ListView.builder(
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
                                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                                onPressed: () {
                                                  removeFromCart(item.product);
                                                  setModalState(() {});
                                                },
                                              ),
                                              Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle, color: Colors.green),
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
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Produtos'),
              ),

              Text(
                'Total: R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),

              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedFly extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String imageUrl;

  const AnimatedFly({super.key, required this.start, required this.end, required this.imageUrl});

  @override
  State<AnimatedFly> createState() => _AnimatedFlyState();
}

class _AnimatedFlyState extends State<AnimatedFly> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = Tween<Offset>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          child: Opacity(
            opacity: 1 - _controller.value,
            child: Image.network(
              widget.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset('assets/no-image.jpeg', width: 50, height: 50),
            ),
          ),
        );
      },
    );
  }
}
