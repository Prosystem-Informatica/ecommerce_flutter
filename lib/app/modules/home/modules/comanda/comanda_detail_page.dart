import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/comanda/model/comanda_item_model.dart';
import '../../../../repositories/comanda/model/observacao_model.dart';
import '../../../../repositories/product/model/consult_product_model.dart';
import '../../../profile/modules/consultProduct/cubit/consult_product_bloc_cubit.dart';
import 'cubit/comanda_cubit.dart';
import 'cubit/comanda_state.dart';

class ComandaDetailPage extends StatefulWidget {
  final String numComanda;

  const ComandaDetailPage({super.key, required this.numComanda});

  @override
  State<ComandaDetailPage> createState() => _ComandaDetailPageState();
}

/// Modelo local para itens adicionados mas ainda não enviados ao servidor.
class _PendingItem {
  final String codigo;
  final String produto;
  final double quantidade;
  final double prcUnit;
  final String obs;

  const _PendingItem({
    required this.codigo,
    required this.produto,
    required this.quantidade,
    required this.prcUnit,
    required this.obs,
  });
}

class _ComandaDetailPageState extends State<ComandaDetailPage> {
  /// Itens pendentes ainda não enviados ao servidor.
  final List<_PendingItem> _pendingItems = [];

  @override
  void initState() {
    super.initState();
    context.read<ComandaCubit>().consultarComanda(widget.numComanda);
  }

  String _formatarValor(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  // ── Remover item ──────────────────────────────────────────────────────────

  Future<void> _removerItem(ComandaItemModel item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover item'),
        content: Text('Deseja remover "${item.produto}" da comanda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final ok = await context.read<ComandaCubit>().removerItem(
          numComanda: widget.numComanda,
          idItem: item.id,
        );

    if (mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover item')),
      );
    }
  }

  // ── Adicionar item (fluxo completo) ───────────────────────────────────────

  Future<void> _adicionarItem() async {
    final cubit = context.read<ComandaCubit>();
    final consultCubit = context.read<ConsultProductBlocCubit>();
    final produtos = consultCubit.state.products ?? [];

    // 1. Selecionar produto
    ConsultProductModel? selecionado;
    var filteredProd = List<ConsultProductModel>.from(produtos);

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDlg) => AlertDialog(
          title: const Text('Selecionar Produto'),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) {
                    setDlg(() {
                      filteredProd = produtos
                          .where((p) => p.produto
                              .toLowerCase()
                              .contains(v.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredProd.isEmpty
                      ? const Center(child: Text('Nenhum produto encontrado'))
                      : ListView.builder(
                          itemCount: filteredProd.length,
                          itemBuilder: (_, i) {
                            final p = filteredProd[i];
                            return ListTile(
                              title: Text(p.produto),
                              subtitle: Text('R\$ ${p.preco}'),
                              onTap: () {
                                selecionado = p;
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );

    if (selecionado == null || !mounted) return;

    // 2. Carrega obs pré-cadastradas em paralelo antes de abrir o modal
    final obsPreRegistradas = await cubit.getObservacoes();
    if (!mounted) return;

    // 3. Modal único: Quantidade + Observação
    final quantCtrl = TextEditingController(text: '1');
    final customObsCtrl = TextEditingController();
    final selectedCodigos = <String>{};
    bool confirmado = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDlg) {
          final primaryColor = Theme.of(context).colorScheme.primary;

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Adicionar Item',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  selecionado!.produto,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Quantidade ──────────────────────────────────
                    const Text(
                      'Quantidade',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: quantCtrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d{0,3}')),
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Observações pré-cadastradas ─────────────────
                    if (obsPreRegistradas.isNotEmpty) ...[
                      const Text(
                        'Observações pré-cadastradas',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      ...obsPreRegistradas.map(
                        (obs) => CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(obs.descricao,
                              style: const TextStyle(fontSize: 14)),
                          value: selectedCodigos.contains(obs.codigo),
                          activeColor: primaryColor,
                          onChanged: (v) {
                            setDlg(() {
                              if (v == true) {
                                selectedCodigos.add(obs.codigo);
                              } else {
                                selectedCodigos.remove(obs.codigo);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ── Observação livre ────────────────────────────
                    const Text(
                      'Observação livre',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: customObsCtrl,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ex: sem cebola, bem passado...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  confirmado = true;
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );

    if (!confirmado || !mounted) return;

    // Valida quantidade
    final quantidade =
        double.tryParse(quantCtrl.text.replaceAll(',', '.'));
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida')),
      );
      return;
    }

    // Monta string de observação
    final partes = <String>[];
    for (final codigo in selectedCodigos) {
      final obs = obsPreRegistradas.firstWhere(
        (o) => o.codigo == codigo,
        orElse: () => const ObservacaoModel(),
      );
      if (obs.descricao.isNotEmpty) partes.add(obs.descricao);
    }
    final livre = customObsCtrl.text.trim();
    if (livre.isNotEmpty) partes.add(livre);
    final obs = partes.join(', ');

    // 4. Adiciona ao carrinho local — será enviado ao pressionar Salvar
    final prcUnit =
        double.tryParse(selecionado!.preco.replaceAll(',', '.')) ?? 0;

    if (!mounted) return;
    setState(() {
      _pendingItems.add(_PendingItem(
        codigo: selecionado!.codigo,
        produto: selecionado!.produto,
        quantidade: quantidade,
        prcUnit: prcUnit,
        obs: obs,
      ));
    });
  }

  // ── Salvar itens pendentes ─────────────────────────────────────────────────

  Future<void> _salvar() async {
    if (_pendingItems.isEmpty) return;
    final cubit = context.read<ComandaCubit>();

    // Lê a mesa a partir dos itens já gravados na comanda, se disponível
    final mesa =
        cubit.state.consultaAtual?.dados.isNotEmpty == true
            ? cubit.state.consultaAtual!.dados.first.mesa
            : '';

    final itens = _pendingItems.map((item) {
      final qtdStr = item.quantidade % 1 == 0
          ? item.quantidade.toStringAsFixed(0)
          : item.quantidade.toStringAsFixed(2);
      final prcStr =
          item.prcUnit.toStringAsFixed(2).replaceAll(',', '.');
      return {
        'ID_PROD': item.codigo,
        'QtdProd': qtdStr,
        'PrcUnit': prcStr,
        'ObsProduto': item.obs,
      };
    }).toList();

    final ok = await cubit.salvarComandaItens(
      numComanda: widget.numComanda,
      numMesa: mesa,
      itens: itens,
    );

    if (!mounted) return;

    if (ok) {
      setState(() => _pendingItems.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itens salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      await cubit.consultarComanda(widget.numComanda);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar itens'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comanda #${widget.numComanda}'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => context
                .read<ComandaCubit>()
                .consultarComanda(widget.numComanda),
          ),
        ],
      ),
      // FAB de Salvar — aparece somente quando há itens pendentes
      floatingActionButton: _pendingItems.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _salvar,
              backgroundColor: primaryColor,
              icon: const Icon(Icons.save),
              label: Text('Salvar (${_pendingItems.length})'),
            ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bg-login.jpg', fit: BoxFit.cover),
          ),
          BlocBuilder<ComandaCubit, ComandaState>(
            buildWhen: (prev, curr) =>
                prev.consultaStatus != curr.consultaStatus ||
                prev.consultaAtual != curr.consultaAtual,
            builder: (ctx, state) {
              if (state.consultaStatus == ComandaConsultaStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.consultaStatus == ComandaConsultaStatus.error) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          state.consultaErro ?? 'Erro ao carregar comanda'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ctx
                            .read<ComandaCubit>()
                            .consultarComanda(widget.numComanda),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              final consulta = state.consultaAtual;
              if (consulta == null) {
                return const Center(
                    child: Text('Nenhuma comanda carregada'));
              }

              return Column(
                children: [
                  // Card totalizador
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Card(
                      color: Colors.orange[50],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt_long,
                                    color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  '${consulta.dados.length} '
                                  '${consulta.dados.length == 1 ? 'item' : 'itens'}',
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total',
                                    style: TextStyle(fontSize: 12)),
                                Text(
                                  _formatarValor(consulta.totalComanda),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Header itens + botão adicionar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Itens',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.add, color: primaryColor),
                          label: Text('Adicionar Item',
                              style: TextStyle(color: primaryColor)),
                          onPressed: _adicionarItem,
                        ),
                      ],
                    ),
                  ),

                  // Itens pendentes (ainda não enviados)
                  if (_pendingItems.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Card(
                          color: Colors.amber[50],
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.orange.shade300, width: 1),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12, 8, 8, 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.pending_actions,
                                        size: 16,
                                        color: Colors.orange[700]),
                                    const SizedBox(width: 6),
                                    Text(
                                      'A confirmar (${_pendingItems.length})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  itemCount: _pendingItems.length,
                                  itemBuilder: (_, i) {
                                    final p = _pendingItems[i];
                                    final qtdStr = p.quantidade % 1 == 0
                                        ? p.quantidade.toStringAsFixed(0)
                                        : p.quantidade.toStringAsFixed(2);
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 0),
                                      title: Text(
                                        p.produto,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'Qtd: $qtdStr  •  ${_formatarValor(p.prcUnit)}'
                                        '${p.obs.isNotEmpty ? '  •  ${p.obs}' : ''}',
                                        style:
                                            const TextStyle(fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 16, color: Colors.red),
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(),
                                        onPressed: () => setState(
                                            () => _pendingItems.removeAt(i)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Lista de itens confirmados
                  Expanded(
                    child: consulta.dados.isEmpty
                        ? const Center(
                            child: Text('Nenhum item na comanda'))
                        : RefreshIndicator(
                            onRefresh: () => ctx
                                .read<ComandaCubit>()
                                .consultarComanda(widget.numComanda),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              itemCount: consulta.dados.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (_, i) {
                                final item = consulta.dados[i];
                                final qtdStr = item.quant % 1 == 0
                                    ? item.quant.toStringAsFixed(0)
                                    : item.quant.toStringAsFixed(2);
                                return Card(
                                  color: Colors.white.withOpacity(0.92),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.produto,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Qtd: $qtdStr  •  Unit: ${_formatarValor(item.prcUnit)}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              if (item.obsProduto.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Icon(
                                                        Icons.chat_bubble_outline,
                                                        size: 12,
                                                        color:
                                                            Colors.grey[500],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          item.obsProduto,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[600],
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _formatarValor(item.total),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red,
                                                  size: 20),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () =>
                                                  _removerItem(item),
                                            ),
                                          ],
                                        ),
                                      ],
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
