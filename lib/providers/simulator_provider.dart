import 'package:flutter/foundation.dart';
import '../models/trade_info.dart';
import '../models/symbol_dto.dart';
import '../services/api_service.dart';

class SimulatorProvider extends ChangeNotifier {
  int riskAmount = kRiskAmount;
  int firstLotRatio = kFirstLotRatio;
  double priceJpy = 0;

  TradeEntry entry = TradeEntry(symbol: 'GBPUSD', tradeType: 'L');
  List<TradePosition> positionList = [
    TradePosition(positionNumber: 1),
    TradePosition(positionNumber: 2),
    TradePosition(positionNumber: 3),
  ];
  TradeSimulationResponse? response;
  bool isLoading = false;
  String? errorMessage;

  List<SymbolDto> symbolList = [];
  bool isInitialized = false;

  final ApiService _api = ApiService();

  Future<void> initialize() async {
    if (isInitialized) return;
    try {
      final list = await _api.getList('/v1/fx/symbol/currency-pair-list');
      symbolList = list.map((e) => SymbolDto.fromJson(e as Map<String, dynamic>)).toList();
      isInitialized = true;
      notifyListeners();
      await calculate();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> calculate() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final req = TradeSimulationRequest(
        riskAmount: riskAmount,
        firstLotRatio: firstLotRatio,
        entry: entry.copyWith(priceJpy: priceJpy),
        positionList: positionList,
      );
      final res = await _api.post('/v1/fx/trade/simulation', req.toJson());
      final parsed = TradeSimulationResponse.fromJson(res);
      entry = parsed.entry;
      positionList = positionPadding3(parsed.positionList);
      response = parsed;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEntry(TradeEntry next) async {
    final symbolChanged = next.symbol != entry.symbol || next.tradeType != entry.tradeType;
    entry = symbolChanged ? next.copyWith(contractPrice: 0, lossPrice: 0) : next;
    if (symbolChanged) {
      positionList = [
        TradePosition(positionNumber: 1),
        TradePosition(positionNumber: 2),
        TradePosition(positionNumber: 3),
      ];
      notifyListeners();
      await calculate();
    } else {
      notifyListeners();
    }
  }

  void updatePosition(int index, TradePosition pos) {
    final next = List<TradePosition>.from(positionList);
    next[index] = pos;
    positionList = next;
    notifyListeners();
  }

  Future<void> setRiskAmount(int v) async {
    riskAmount = v;
    notifyListeners();
    await calculate();
  }

  Future<void> setFirstLotRatio(int v) async {
    firstLotRatio = v;
    notifyListeners();
    await calculate();
  }

  void setPriceJpy(double v) {
    priceJpy = v;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
