import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/comanda/model/comanda_model.dart';
import 'comanda_detail_page.dart';
import 'cubit/comanda_cubit.dart';
import 'cubit/comanda_state.dart';

class ComandaPage extends StatefulWidget {
  const ComandaPage({super.key});

  @override
  State<ComandaPage> createState() => _ComandaPageState();
}

class _ComandaPageState extends State<ComandaPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ComandaCubit>().carregarComandas();
  }

  List<ComandaModel> _filtrar(List<ComandaModel> all) {
    if (searchQuery.trim().isEmpty) return all;
    return all
        .where((c) => c.numero.contains(searchQuery.trim()))
        .toList();
  }

  String _formatarValor(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
          ),
          BlocBuilder<ComandaCubit, ComandaState>(
            buildWhen: (prev, curr) =>
                prev.listaStatus != curr.listaStatus ||
                prev.listaComandas != curr.listaComandas,
            builder: (ctx, state) {
              if (state.listaStatus == ComandaListaStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.listaStatus == ComandaListaStatus.error) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.listaErro ?? 'Erro ao carregar comandas'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ctx.read<ComandaCubit>().carregarComandas(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              final lista = state.listaComandas;
              final comandas = _filtrar(lista?.dados ?? []);

              return Column(
                children: [
                  // Total geral
                  if (lista != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Card(
                        color: Colors.orange[50],
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total em aberto',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _formatarValor(lista.totalGeral),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Campo de busca por número
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar por número da comanda...',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
                      ),
                      onChanged: (v) => setState(() => searchQuery = v),
                    ),
                  ),

                  // Lista de comandas
                  Expanded(
                    child: state.listaStatus == ComandaListaStatus.initial
                        ? const SizedBox.shrink()
                        : comandas.isEmpty
                            ? Center(
                                child: Text(
                                  searchQuery.isNotEmpty
                                      ? 'Nenhuma comanda encontrada'
                                      : 'Nenhuma comanda em aberto',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    ctx.read<ComandaCubit>().carregarComandas(),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  itemCount: comandas.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, i) {
                                    final comanda = comandas[i];
                                    return Card(
                                      color: Colors.orange[50],
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ComandaDetailPage(
                                                numComanda: comanda.numero,
                                              ),
                                            ),
                                          ).then((_) {
                                            // Recarrega a lista ao voltar
                                            ctx
                                                .read<ComandaCubit>()
                                                .carregarComandas();
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              Icon(Icons.receipt_long,
                                                  color: primaryColor,
                                                  size: 32),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Comanda #${comanda.numero}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Data: ${comanda.data}',
                                                      style: const TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatarValor(
                                                        comanda.total),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      'ABERTO',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.green[800],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.chevron_right,
                                                  color: Colors.grey[500]),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
