import '../../../../../repositories/comanda/model/comanda_consulta_model.dart';
import '../../../../../repositories/comanda/model/comanda_lista_model.dart';

enum ComandaListaStatus { initial, loading, success, error }

enum ComandaConsultaStatus { initial, loading, success, error }

class ComandaState {
  final ComandaListaStatus listaStatus;
  final ComandaConsultaStatus consultaStatus;
  final ComandaListaModel? listaComandas;
  final ComandaConsultaModel? consultaAtual;
  final String? listaErro;
  final String? consultaErro;

  const ComandaState({
    required this.listaStatus,
    required this.consultaStatus,
    this.listaComandas,
    this.consultaAtual,
    this.listaErro,
    this.consultaErro,
  });

  ComandaState.initial()
      : listaStatus = ComandaListaStatus.initial,
        consultaStatus = ComandaConsultaStatus.initial,
        listaComandas = null,
        consultaAtual = null,
        listaErro = null,
        consultaErro = null;

  ComandaState copyWith({
    ComandaListaStatus? listaStatus,
    ComandaConsultaStatus? consultaStatus,
    ComandaListaModel? listaComandas,
    ComandaConsultaModel? consultaAtual,
    String? listaErro,
    String? consultaErro,
  }) {
    return ComandaState(
      listaStatus: listaStatus ?? this.listaStatus,
      consultaStatus: consultaStatus ?? this.consultaStatus,
      listaComandas: listaComandas ?? this.listaComandas,
      consultaAtual: consultaAtual ?? this.consultaAtual,
      listaErro: listaErro ?? this.listaErro,
      consultaErro: consultaErro ?? this.consultaErro,
    );
  }
}
