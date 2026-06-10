const int kRiskAmount = 5000;
const int kFirstLotRatio = 30;

class TradeEntry {
  int id;
  String tradeVersion;
  String symbol;
  String tradeType;
  String contractAt;
  String entryType;
  String fibonacciType;
  String fibonacciBar;
  double contractPrice;
  double lossPrice;
  int positionRatio;
  double priceJpy;
  double lot;
  int settlementAmount;
  int lossPips;
  double settlementRatio;
  String comment;
  String imagePath;

  TradeEntry({
    this.id = 0,
    this.tradeVersion = 'V0',
    this.symbol = 'USDJPY',
    this.tradeType = 'L',
    String? contractAt,
    this.entryType = 'F3',
    this.fibonacciType = 'RV',
    this.fibonacciBar = '15M',
    this.contractPrice = 0,
    this.lossPrice = 0,
    this.positionRatio = kFirstLotRatio,
    this.priceJpy = 0,
    this.lot = 0,
    this.settlementAmount = 0,
    this.lossPips = 0,
    this.settlementRatio = 0,
    this.comment = '',
    this.imagePath = '',
  }) : contractAt = contractAt ?? _nowDateTimeString();

  static String _nowDateTimeString() {
    final d = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final offset = d.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final offsetH = pad(offset.inHours.abs());
    final offsetM = pad(offset.inMinutes.abs() % 60);
    return '${d.year}-${pad(d.month)}-${pad(d.day)}T${pad(d.hour)}:${pad(d.minute)}:00$sign$offsetH:$offsetM';
  }

  TradeEntry copyWith({
    int? id,
    String? tradeVersion,
    String? symbol,
    String? tradeType,
    String? contractAt,
    String? entryType,
    String? fibonacciType,
    String? fibonacciBar,
    double? contractPrice,
    double? lossPrice,
    int? positionRatio,
    double? priceJpy,
    double? lot,
    int? settlementAmount,
    int? lossPips,
    double? settlementRatio,
    String? comment,
    String? imagePath,
  }) =>
      TradeEntry(
        id: id ?? this.id,
        tradeVersion: tradeVersion ?? this.tradeVersion,
        symbol: symbol ?? this.symbol,
        tradeType: tradeType ?? this.tradeType,
        contractAt: contractAt ?? this.contractAt,
        entryType: entryType ?? this.entryType,
        fibonacciType: fibonacciType ?? this.fibonacciType,
        fibonacciBar: fibonacciBar ?? this.fibonacciBar,
        contractPrice: contractPrice ?? this.contractPrice,
        lossPrice: lossPrice ?? this.lossPrice,
        positionRatio: positionRatio ?? this.positionRatio,
        priceJpy: priceJpy ?? this.priceJpy,
        lot: lot ?? this.lot,
        settlementAmount: settlementAmount ?? this.settlementAmount,
        lossPips: lossPips ?? this.lossPips,
        settlementRatio: settlementRatio ?? this.settlementRatio,
        comment: comment ?? this.comment,
        imagePath: imagePath ?? this.imagePath,
      );

  factory TradeEntry.fromJson(Map<String, dynamic> json) => TradeEntry(
        id: json['id'] as int? ?? 0,
        tradeVersion: json['tradeVersion'] as String? ?? 'V0',
        symbol: json['symbol'] as String? ?? 'USDJPY',
        tradeType: json['tradeType'] as String? ?? 'L',
        contractAt: json['contractAt'] as String? ?? _nowDateTimeString(),
        entryType: json['entryType'] as String? ?? 'F3',
        fibonacciType: json['fibonacciType'] as String? ?? 'RV',
        fibonacciBar: json['fibonacciBar'] as String? ?? '15M',
        contractPrice: (json['contractPrice'] as num?)?.toDouble() ?? 0,
        lossPrice: (json['lossPrice'] as num?)?.toDouble() ?? 0,
        positionRatio: json['positionRatio'] as int? ?? kFirstLotRatio,
        priceJpy: (json['priceJpy'] as num?)?.toDouble() ?? 0,
        lot: (json['lot'] as num?)?.toDouble() ?? 0,
        settlementAmount: json['settlementAmount'] as int? ?? 0,
        lossPips: json['lossPips'] as int? ?? 0,
        settlementRatio: (json['settlementRatio'] as num?)?.toDouble() ?? 0,
        comment: json['comment'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != 0) 'id': id,
        'tradeVersion': tradeVersion,
        'symbol': symbol,
        'tradeType': tradeType,
        'contractAt': contractAt,
        'entryType': entryType,
        'fibonacciType': fibonacciType,
        'fibonacciBar': fibonacciBar,
        'contractPrice': contractPrice,
        'lossPrice': lossPrice,
        'positionRatio': positionRatio,
        'priceJpy': priceJpy,
        'lot': lot,
        'settlementAmount': settlementAmount,
        'lossPips': lossPips,
        'settlementRatio': settlementRatio,
        'comment': comment,
        'imagePath': imagePath,
      };
}

class TradePosition {
  int id;
  int positionNumber;
  double settlementPrice;
  int settlementPips;
  double settlementRatio;
  double lot;
  int profitAmount;
  int lossAmount;

  TradePosition({
    this.id = 0,
    required this.positionNumber,
    this.settlementPrice = 0,
    this.settlementPips = 0,
    this.settlementRatio = 0,
    this.lot = 0,
    this.profitAmount = 0,
    this.lossAmount = 0,
  });

  TradePosition copyWith({
    int? id,
    int? positionNumber,
    double? settlementPrice,
    int? settlementPips,
    double? settlementRatio,
    double? lot,
    int? profitAmount,
    int? lossAmount,
  }) =>
      TradePosition(
        id: id ?? this.id,
        positionNumber: positionNumber ?? this.positionNumber,
        settlementPrice: settlementPrice ?? this.settlementPrice,
        settlementPips: settlementPips ?? this.settlementPips,
        settlementRatio: settlementRatio ?? this.settlementRatio,
        lot: lot ?? this.lot,
        profitAmount: profitAmount ?? this.profitAmount,
        lossAmount: lossAmount ?? this.lossAmount,
      );

  factory TradePosition.fromJson(Map<String, dynamic> json) => TradePosition(
        id: json['id'] as int? ?? 0,
        positionNumber: json['positionNumber'] as int,
        settlementPrice: (json['settlementPrice'] as num?)?.toDouble() ?? 0,
        settlementPips: json['settlementPips'] as int? ?? 0,
        settlementRatio: (json['settlementRatio'] as num?)?.toDouble() ?? 0,
        lot: (json['lot'] as num?)?.toDouble() ?? 0,
        profitAmount: json['profitAmount'] as int? ?? 0,
        lossAmount: json['lossAmount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (id != 0) 'id': id,
        'positionNumber': positionNumber,
        'settlementPrice': settlementPrice,
        'settlementPips': settlementPips,
        'settlementRatio': settlementRatio,
        'lot': lot,
        'profitAmount': profitAmount,
        'lossAmount': lossAmount,
      };
}

class TradeSimulationRequest {
  final int riskAmount;
  final int firstLotRatio;
  final TradeEntry entry;
  final List<TradePosition> positionList;

  TradeSimulationRequest({
    required this.riskAmount,
    required this.firstLotRatio,
    required this.entry,
    required this.positionList,
  });

  Map<String, dynamic> toJson() => {
        'riskAmount': riskAmount,
        'firstLotRatio': firstLotRatio,
        'entry': entry.toJson(),
        'positionList': positionList.map((p) => p.toJson()).toList(),
      };
}

class TradeSimulationResponse {
  final int returnCode;
  final String? message;
  final TradeEntry entry;
  final List<TradePosition> positionList;

  TradeSimulationResponse({
    required this.returnCode,
    this.message,
    required this.entry,
    required this.positionList,
  });

  factory TradeSimulationResponse.fromJson(Map<String, dynamic> json) {
    final rawCode = json['returnCode'];
    final returnCode = rawCode is int ? rawCode : int.parse(rawCode.toString());
    return TradeSimulationResponse(
      returnCode: returnCode,
      message: json['message'] as String?,
      entry: TradeEntry.fromJson(json['entry'] as Map<String, dynamic>),
      positionList: (json['positionList'] as List)
          .map((e) => TradePosition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

List<TradePosition> positionPadding3(List<TradePosition> list) {
  if (list.length >= 3) return list.take(3).toList();
  final result = [list[0]];
  if (list.length == 1) {
    result.add(TradePosition(positionNumber: 2));
    result.add(TradePosition(positionNumber: 3));
  } else {
    result.add(list[1]);
    result.add(TradePosition(positionNumber: 3));
  }
  return result;
}
