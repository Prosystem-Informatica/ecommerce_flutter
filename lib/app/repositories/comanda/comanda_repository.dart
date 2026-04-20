import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/rest/rest_client.dart';
import 'model/comanda_consulta_model.dart';
import 'model/comanda_lista_model.dart';
import 'model/observacao_model.dart';

class ComandaRepository {
  final RestClient _rest;

  ComandaRepository({required RestClient rest}) : _rest = rest;

  Future<void> _reloadBaseUrl() async {
    await _rest.reloadBaseUrl();
  }

  /// Lista todas as comandas em aberto.
  /// Endpoint: GET /datasnap/rest/TServerAPPecf/RetornaComandas
  Future<ComandaListaModel?> getComandas() async {
    try {
      await _reloadBaseUrl();
      final response = await _rest.get(
        '/datasnap/rest/TServerAPPecf/RetornaComandas',
      );
      final data = response.data;

      log("RetornaComandas: $data");

      if (data is Map<String, dynamic>) {
        return ComandaListaModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Consulta os itens e o total de uma comanda pelo número.
  /// Endpoint: GET /datasnap/rest/TServerAPPecf/ConsultaComanda/{numComanda}
  Future<ComandaConsultaModel?> consultarComanda(String numComanda) async {
    try {
      await _reloadBaseUrl();
      final response = await _rest.get(
        '/datasnap/rest/TServerAPPecf/ConsultaComanda/$numComanda',
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ComandaConsultaModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Retorna as observações pré-cadastradas no sistema.
  /// Endpoint: GET /datasnap/rest/TServerAPPecf/RetornaObservacoes
  Future<List<ObservacaoModel>> getObservacoes() async {
    try {
      await _reloadBaseUrl();
      final response = await _rest.get(
        '/datasnap/rest/TServerAPPecf/RetornaObservacoes',
      );
      final data = response.data;

      if (data is List) return ObservacaoModel.fromJsonList(data);
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Adiciona um item à comanda via fluxo GravaPed2 (restaurante).
  /// Reutiliza o mesmo GravaPed2 do ecommerce, agora com Comanda/Mesa/Obs no path.
  /// Fluxo: IncluirPedido → GravaPed1 → GravaPed2(+comanda) → ConfirmaPed
  Future<bool> adicionarItem({
    required String numComanda,
    required String codProd,
    required double quant,
    required double prcUnit,
    String mesa = '',
    String obs = '',
  }) async {
    try {
      await _reloadBaseUrl();

      final prefs = await SharedPreferences.getInstance();
      final idEmpresa = prefs.getString('companyCodigo') ?? '0';
      final idVendedor = prefs.getString('userCodigo') ?? '0';

      // 1. Gera novo número de pedido
      final pedResponse = await _rest.get(
        '/datasnap/rest/TServerAPPecf/IncluirPedido',
      );
      final numPed = pedResponse.data?.toString() ?? '';
      if (numPed.isEmpty) return false;
      log('IncluirPedido (comanda): numPed=$numPed');

      // 2. Grava cabeçalho do pedido
      final totalStr = (quant * prcUnit).toStringAsFixed(2).replaceAll('.', ',');
      await _rest.get(
        '/datasnap/rest/TServerAPPecf/GravaPed1/$idEmpresa/$numPed/$idVendedor/0/0/0/0/-/$totalStr',
      );

      // 3. Grava item com número de comanda
      //    GravaPed2(Numped, ID_PROD, QtdProd, PrcUnit, Comanda, Mesa, ObsProduto)
      final quantStr = quant.toStringAsFixed(2).replaceAll('.', ',');
      final prcStr = prcUnit.toStringAsFixed(2).replaceAll('.', ',');

      var path =
          '/datasnap/rest/TServerAPPecf/GravaPed2/$numPed/$codProd/$quantStr/$prcStr/$numComanda';

      final mesaTrimmed = mesa.trim();
      final obsTrimmed = obs.trim();

      if (obsTrimmed.isNotEmpty) {
        // Mesa precisa vir antes de Obs; usa 0 quando não informada
        path += '/${mesaTrimmed.isEmpty ? '0' : mesaTrimmed}/$obsTrimmed';
      } else if (mesaTrimmed.isNotEmpty) {
        path += '/$mesaTrimmed';
      }

      log('GravaPed2 (comanda): $path');
      await _rest.get(path);

      // 4. Confirma pedido
      final confirmResponse = await _rest.get(
        '/datasnap/rest/TServerAPPecf/ConfirmaPed/$numPed',
      );
      final confirmado = confirmResponse.data?.toString().toUpperCase() ?? '';
      log('ConfirmaPed (comanda): $confirmado');
      return confirmado == 'T' || confirmado == 'TRUE';
    } catch (e) {
      log('Erro ao adicionar item na comanda: $e');
      return false;
    }
  }

  /// Cria uma nova comanda com os itens enviados via POST JSON.
  /// Endpoint: POST /datasnap/rest/TServerAPPecf/SalvarComanda
  /// Body: { "comanda": { IdEmpresa, Numcomanda, NumMesa }, "ItensComanda": [...] }
  Future<bool> salvarComanda({
    required String idEmpresa,
    required String numComanda,
    required String numMesa,
    required List<Map<String, dynamic>> itens,
  }) async {
    try {
      await _reloadBaseUrl();
      final body = jsonEncode({
        'comanda': {
          'IdEmpresa': int.tryParse(idEmpresa) ?? 0,
          'Numcomanda': numComanda,
          'NumMesa': numMesa,
        },
        'ItensComanda': itens,
      });
      log('SalvarComanda body: $body');
      final response = await _rest.post(
        '/datasnap/rest/TServerAPPecf/SalvarComanda',
        data: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Erro ao salvar comanda: $e');
      return false;
    }
  }

  /// Remove um item da comanda pelo id do item.
  /// Endpoint: a confirmar com o back-end.
  Future<bool> removerItem({
    required String numComanda,
    required String idItem,
  }) async {
    try {
      await _reloadBaseUrl();
      await _rest.post(
        '/datasnap/rest/TServerAPPecf/ExcluirItemComanda/$numComanda/$idItem',
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
