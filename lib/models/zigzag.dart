class Fibonacci {
  final double priceRange;
  final double f0, f1, f2, f3, f5, f6, f7;

  Fibonacci({
    required this.priceRange,
    required this.f0,
    required this.f1,
    required this.f2,
    required this.f3,
    required this.f5,
    required this.f6,
    required this.f7,
  });

  factory Fibonacci.fromJson(Map<String, dynamic> json) => Fibonacci(
        priceRange: (json['priceRange'] as num?)?.toDouble() ?? 0,
        f0: (json['f0'] as num?)?.toDouble() ?? 0,
        f1: (json['f1'] as num?)?.toDouble() ?? 0,
        f2: (json['f2'] as num?)?.toDouble() ?? 0,
        f3: (json['f3'] as num?)?.toDouble() ?? 0,
        f5: (json['f5'] as num?)?.toDouble() ?? 0,
        f6: (json['f6'] as num?)?.toDouble() ?? 0,
        f7: (json['f7'] as num?)?.toDouble() ?? 0,
      );
}

class Sma {
  final double priceS, priceE, deviation, fibonacci;
  final int direction, position;

  Sma({
    required this.priceS,
    required this.priceE,
    required this.deviation,
    required this.fibonacci,
    required this.direction,
    required this.position,
  });

  factory Sma.fromJson(Map<String, dynamic> json) => Sma(
        priceS: (json['priceS'] as num?)?.toDouble() ?? 0,
        priceE: (json['priceE'] as num?)?.toDouble() ?? 0,
        deviation: (json['deviation'] as num?)?.toDouble() ?? 0,
        fibonacci: (json['fibonacci'] as num?)?.toDouble() ?? 0,
        direction: json['direction'] as int? ?? 0,
        position: json['position'] as int? ?? 0,
      );
}

class ZigZagInfo {
  final String waveStart;
  final String waveEnd;
  final int wave;
  final double resistance;
  final double support;

  ZigZagInfo({
    required this.waveStart,
    required this.waveEnd,
    required this.wave,
    required this.resistance,
    required this.support,
  });

  factory ZigZagInfo.fromJson(Map<String, dynamic> json) => ZigZagInfo(
        waveStart: json['waveStart'] as String? ?? '',
        waveEnd: json['waveEnd'] as String? ?? '',
        wave: json['wave'] as int? ?? 0,
        resistance: (json['resistance'] as num?)?.toDouble() ?? 0,
        support: (json['support'] as num?)?.toDouble() ?? 0,
      );
}

class ZigZagInfoSma extends ZigZagInfo {
  final Fibonacci fibonacci;
  final Sma sma4h200s;

  ZigZagInfoSma({
    required super.waveStart,
    required super.waveEnd,
    required super.wave,
    required super.resistance,
    required super.support,
    required this.fibonacci,
    required this.sma4h200s,
  });

  factory ZigZagInfoSma.fromJson(Map<String, dynamic> json) => ZigZagInfoSma(
        waveStart: json['waveStart'] as String? ?? '',
        waveEnd: json['waveEnd'] as String? ?? '',
        wave: json['wave'] as int? ?? 0,
        resistance: (json['resistance'] as num?)?.toDouble() ?? 0,
        support: (json['support'] as num?)?.toDouble() ?? 0,
        fibonacci: json['fibonacci'] != null
            ? Fibonacci.fromJson(json['fibonacci'] as Map<String, dynamic>)
            : Fibonacci(priceRange: 0, f0: 0, f1: 0, f2: 0, f3: 0, f5: 0, f6: 0, f7: 0),
        sma4h200s: json['sma4h200s'] != null
            ? Sma.fromJson(json['sma4h200s'] as Map<String, dynamic>)
            : Sma(priceS: 0, priceE: 0, deviation: 0, fibonacci: 0, direction: 0, position: 0),
      );
}

class FractalWave {
  final String waveStart;
  final int wave;

  FractalWave({required this.waveStart, required this.wave});

  factory FractalWave.fromJson(Map<String, dynamic> json) => FractalWave(
        waveStart: json['waveStart'] as String? ?? '',
        wave: json['wave'] as int? ?? 0,
      );
}

class ZigZagResult {
  final String symbol;
  final int depth;
  final ZigZagInfoSma current;
  final ZigZagInfoSma target4h;
  final ZigZagInfo previous;
  final ZigZagInfo next;
  final ZigZagInfo next2;
  final double nextRsRate;
  final double next2MaxRate;
  final double waveDxy4h;
  final double waveDxy1h;
  final List<FractalWave> fractalWaveList;

  ZigZagResult({
    required this.symbol,
    required this.depth,
    required this.current,
    required this.target4h,
    required this.previous,
    required this.next,
    required this.next2,
    required this.nextRsRate,
    required this.next2MaxRate,
    required this.waveDxy4h,
    required this.waveDxy1h,
    required this.fractalWaveList,
  });

  factory ZigZagResult.fromJson(Map<String, dynamic> json) => ZigZagResult(
        symbol: json['symbol'] as String? ?? '',
        depth: json['depth'] as int? ?? 0,
        current: ZigZagInfoSma.fromJson(json['current'] as Map<String, dynamic>),
        target4h: ZigZagInfoSma.fromJson(json['target4h'] as Map<String, dynamic>),
        previous: ZigZagInfo.fromJson(json['previous'] as Map<String, dynamic>),
        next: ZigZagInfo.fromJson(json['next'] as Map<String, dynamic>),
        next2: ZigZagInfo.fromJson(json['next2'] as Map<String, dynamic>),
        nextRsRate: (json['nextRsRate'] as num?)?.toDouble() ?? 0,
        next2MaxRate: (json['next2MaxRate'] as num?)?.toDouble() ?? 0,
        waveDxy4h: (json['waveDxy4h'] as num?)?.toDouble() ?? 0,
        waveDxy1h: (json['waveDxy1h'] as num?)?.toDouble() ?? 0,
        fractalWaveList: (json['fractalWaveList'] as List? ?? [])
            .map((e) => FractalWave.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ZigZagSearchRequest {
  final int page;
  final int size;
  final String barType;
  final String symbol;
  final int depth;
  final int wave;
  final int previousWave;
  final int nextWave;
  final int next2Wave;
  final int direction4h200;
  final int direction4h75;
  final int direction4h20;
  final int direction1h200;
  final int direction15m200;
  final int wave4h;
  final int directionTarget4h200;
  final String barDateTimeMin;
  final String barDateTimeMax;

  ZigZagSearchRequest({
    required this.page,
    required this.size,
    required this.barType,
    required this.symbol,
    required this.depth,
    required this.wave,
    required this.previousWave,
    required this.nextWave,
    required this.next2Wave,
    required this.direction4h200,
    required this.direction4h75,
    required this.direction4h20,
    required this.direction1h200,
    required this.direction15m200,
    required this.wave4h,
    required this.directionTarget4h200,
    required this.barDateTimeMin,
    required this.barDateTimeMax,
  });

  ZigZagSearchRequest copyWith({
    int? page,
    int? size,
    String? barType,
    String? symbol,
    int? depth,
    int? wave,
    int? previousWave,
    int? nextWave,
    int? next2Wave,
    int? direction4h200,
    int? direction4h75,
    int? direction4h20,
    int? direction1h200,
    int? direction15m200,
    int? wave4h,
    int? directionTarget4h200,
    String? barDateTimeMin,
    String? barDateTimeMax,
  }) =>
      ZigZagSearchRequest(
        page: page ?? this.page,
        size: size ?? this.size,
        barType: barType ?? this.barType,
        symbol: symbol ?? this.symbol,
        depth: depth ?? this.depth,
        wave: wave ?? this.wave,
        previousWave: previousWave ?? this.previousWave,
        nextWave: nextWave ?? this.nextWave,
        next2Wave: next2Wave ?? this.next2Wave,
        direction4h200: direction4h200 ?? this.direction4h200,
        direction4h75: direction4h75 ?? this.direction4h75,
        direction4h20: direction4h20 ?? this.direction4h20,
        direction1h200: direction1h200 ?? this.direction1h200,
        direction15m200: direction15m200 ?? this.direction15m200,
        wave4h: wave4h ?? this.wave4h,
        directionTarget4h200: directionTarget4h200 ?? this.directionTarget4h200,
        barDateTimeMin: barDateTimeMin ?? this.barDateTimeMin,
        barDateTimeMax: barDateTimeMax ?? this.barDateTimeMax,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'size': size,
        'barType': barType,
        'symbol': symbol,
        'depth': depth,
        'wave': wave,
        'previousWave': previousWave,
        'nextWave': nextWave,
        'next2Wave': next2Wave,
        'direction4h200': direction4h200,
        'direction4h75': direction4h75,
        'direction4h20': direction4h20,
        'direction1h200': direction1h200,
        'direction15m200': direction15m200,
        'wave4h': wave4h,
        'directionTarget4h200': directionTarget4h200,
        'barDateTimeMin': barDateTimeMin,
        'barDateTimeMax': barDateTimeMax,
      };
}

class ZigZagSearchResponse {
  final int totalCount;
  final int totalPage;
  final List<ZigZagResult> list;

  ZigZagSearchResponse({
    required this.totalCount,
    required this.totalPage,
    required this.list,
  });

  factory ZigZagSearchResponse.fromJson(Map<String, dynamic> json) => ZigZagSearchResponse(
        totalCount: json['totalCount'] as int? ?? 0,
        totalPage: json['totalPage'] as int? ?? 0,
        list: (json['list'] as List? ?? [])
            .map((e) => ZigZagResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ZigZagStatus {
  final String symbol;
  final String barType;
  final String barDateTimeMin;
  final String barDateTimeMax;
  final String barDateTimeMinZigZag;
  final String barDateTimeMaxZigZag;
  final int barCount;
  final int zigzagCount;
  final int breakResistanceCount;
  final int breakSupportCount;
  final int depth;
  final String? message;

  ZigZagStatus({
    required this.symbol,
    required this.barType,
    required this.barDateTimeMin,
    required this.barDateTimeMax,
    required this.barDateTimeMinZigZag,
    required this.barDateTimeMaxZigZag,
    required this.barCount,
    required this.zigzagCount,
    required this.breakResistanceCount,
    required this.breakSupportCount,
    required this.depth,
    this.message,
  });

  ZigZagStatus copyWith({String? message}) => ZigZagStatus(
        symbol: symbol,
        barType: barType,
        barDateTimeMin: barDateTimeMin,
        barDateTimeMax: barDateTimeMax,
        barDateTimeMinZigZag: barDateTimeMinZigZag,
        barDateTimeMaxZigZag: barDateTimeMaxZigZag,
        barCount: barCount,
        zigzagCount: zigzagCount,
        breakResistanceCount: breakResistanceCount,
        breakSupportCount: breakSupportCount,
        depth: depth,
        message: message ?? this.message,
      );

  factory ZigZagStatus.fromJson(Map<String, dynamic> json) => ZigZagStatus(
        symbol: json['symbol'] as String? ?? '',
        barType: json['barType'] as String? ?? '',
        barDateTimeMin: json['barDateTimeMin'] as String? ?? '',
        barDateTimeMax: json['barDateTimeMax'] as String? ?? '',
        barDateTimeMinZigZag: json['barDateTimeMinZigZag'] as String? ?? '',
        barDateTimeMaxZigZag: json['barDateTimeMaxZigZag'] as String? ?? '',
        barCount: json['barCount'] as int? ?? 0,
        zigzagCount: json['zigzagCount'] as int? ?? 0,
        breakResistanceCount: json['breakResistanceCount'] as int? ?? 0,
        breakSupportCount: json['breakSupportCount'] as int? ?? 0,
        depth: json['depth'] as int? ?? 0,
        message: json['message'] as String?,
      );
}

class ZigZagGenerateRequest {
  final String symbol;
  final String symbolType;
  final String barType;
  final int depth;
  final String barDateTime;
  final int loadSize;

  const ZigZagGenerateRequest({
    required this.symbol,
    required this.symbolType,
    required this.barType,
    required this.depth,
    required this.barDateTime,
    required this.loadSize,
  });

  ZigZagGenerateRequest copyWith({
    String? symbol,
    String? symbolType,
    String? barType,
    int? depth,
    String? barDateTime,
    int? loadSize,
  }) =>
      ZigZagGenerateRequest(
        symbol: symbol ?? this.symbol,
        symbolType: symbolType ?? this.symbolType,
        barType: barType ?? this.barType,
        depth: depth ?? this.depth,
        barDateTime: barDateTime ?? this.barDateTime,
        loadSize: loadSize ?? this.loadSize,
      );

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'symbolType': symbolType,
        'barType': barType,
        'depth': depth,
        'barDateTime': barDateTime,
        'loadSize': loadSize,
      };
}

class ZigZagBarData {
  final String barDateTime;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;
  final double sma200;
  final double sma75;
  final double sma20;

  ZigZagBarData({
    required this.barDateTime,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.sma200,
    required this.sma75,
    required this.sma20,
  });

  factory ZigZagBarData.fromJson(Map<String, dynamic> json) => ZigZagBarData(
        barDateTime: json['barDateTime'] as String? ?? '',
        openPrice: (json['openPrice'] as num?)?.toDouble() ?? 0,
        highPrice: (json['highPrice'] as num?)?.toDouble() ?? 0,
        lowPrice: (json['lowPrice'] as num?)?.toDouble() ?? 0,
        closePrice: (json['closePrice'] as num?)?.toDouble() ?? 0,
        sma200: (json['sma200'] as num?)?.toDouble() ?? 0,
        sma75: (json['sma75'] as num?)?.toDouble() ?? 0,
        sma20: (json['sma20'] as num?)?.toDouble() ?? 0,
      );
}
