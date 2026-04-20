import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../repositories/comanda/comanda_repository.dart';
import '../../../../../repositories/comanda/model/observacao_model.dart';
import '../../../../../repositories/product/model/consult_product_model.dart';
import 'comanda_state.dart';

class ComandaCubit extends Cubit<ComandaState> {
  final ComandaRepository repository;

  ComandaCubit({required this.repository}) : super(ComandaState.initial());

  /// Carrega a lista de comandas em aberto.
  Future<void> carregarComandas() async {
    emit(state.copyWith(listaStatus: ComandaListaStatus.loading));
    try {
      final result = await repository.getComandas();
      if (result == null) {
        emit(state.copyWith(
          listaStatus: ComandaListaStatus.error,
          listaErro: 'Nenhuma comanda encontrada',
        ));
        return;
      }
      emit(state.copyWith(
        listaStatus: ComandaListaStatus.success,
        listaComandas: result,
      ));
    } catch (_) {
      emit(state.copyWith(
        listaStatus: ComandaListaStatus.error,
        listaErro: 'Erro ao carregar comandas',
      ));
    }
  }

  /// Consulta os itens de uma comanda específica pelo número.
  Future<void> consultarComanda(String numComanda) async {
    emit(state.copyWith(consultaStatus: ComandaConsultaStatus.loading));
    try {
      final result = await repository.consultarComanda(numComanda);
      if (result == null) {
        emit(state.copyWith(
          consultaStatus: ComandaConsultaStatus.error,
          consultaErro: 'Comanda não encontrada',
        ));
        return;
      }
      emit(state.copyWith(
        consultaStatus: ComandaConsultaStatus.success,
        consultaAtual: result,
      ));
    } catch (_) {
      emit(state.copyWith(
        consultaStatus: ComandaConsultaStatus.error,
        consultaErro: 'Erro ao consultar comanda',
      ));
    }
  }

  /// Retorna as observações pré-cadastradas.
  Future<List<ObservacaoModel>> getObservacoes() async {
    return repository.getObservacoes();
  }

  /// Adiciona um item (com mesa e observação opcionais) e recarrega a comanda.
  Future<bool> adicionarItem({
    required String numComanda,
    required String codProd,
    required double quant,
    required double prcUnit,
    String mesa = '',
    String obs = '',
  }) async {
    final ok = await repository.adicionarItem(
      numComanda: numComanda,
      codProd: codProd,
      quant: quant,
      prcUnit: prcUnit,
      mesa: mesa,
      obs: obs,
    );
    if (ok) await consultarComanda(numComanda);
    return ok;
  }

  /// Cria uma nova comanda com produtos vindos do fluxo do FinishCartPage.
  /// Lê idEmpresa do SharedPreferences e delega ao repositório.
  Future<bool> salvarComanda({
    required String numComanda,
    required String numMesa,
    required List<ConsultProductModel> produtos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final idEmpresa = prefs.getString('companyCodigo') ?? '0';

    final itens = produtos
        .map((p) => {
              'ID_PROD': p.codigo,
              'QtdProd': p.quantidade.toString(),
              'PrcUnit': p.preco.replaceAll(',', '.'),
              'ObsProduto': p.obs,
            })
        .toList();

    return repository.salvarComanda(
      idEmpresa: idEmpresa,
      numComanda: numComanda,
      numMesa: numMesa,
      itens: itens,
    );
  }

  /// Adiciona itens a uma comanda aberta via SalvarComanda.
  /// Usado pela ComandaDetailPage — aceita itens já formatados para suportar
  /// quantidades decimais.
  Future<bool> salvarComandaItens({
    required String numComanda,
    required String numMesa,
    required List<Map<String, dynamic>> itens,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final idEmpresa = prefs.getString('companyCodigo') ?? '0';

    return repository.salvarComanda(
      idEmpresa: idEmpresa,
      numComanda: numComanda,
      numMesa: numMesa,
      itens: itens,
    );
  }

  /// Remove um item e recarrega a comanda.
  Future<bool> removerItem({
    required String numComanda,
    required String idItem,
  }) async {
    final ok = await repository.removerItem(
      numComanda: numComanda,
      idItem: idItem,
    );
    if (ok) await consultarComanda(numComanda);
    return ok;
  }
}
