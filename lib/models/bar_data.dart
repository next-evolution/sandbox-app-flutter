class KeyValue {
  final String key;
  final String value;
  KeyValue({required this.key, required this.value});
  factory KeyValue.fromJson(Map<String, dynamic> json) => KeyValue(
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );
}

class BarDataSearchRequest {
  final int page;
  final int size;
  final String barType;
  final String symbol;
  final String? barDateFrom;
  final String? barDateTo;
  final bool? sortAsc;

  BarDataSearchRequest({
    required this.page,
    required this.size,
    required this.barType,
    required this.symbol,
    this.barDateFrom,
    this.barDateTo,
    this.sortAsc,
  });

  BarDataSearchRequest copyWith({
    int? page,
    int? size,
    String? barType,
    String? symbol,
    String? barDateFrom,
    String? barDateTo,
    bool? sortAsc,
  }) =>
      BarDataSearchRequest(
        page: page ?? this.page,
        size: size ?? this.size,
        barType: barType ?? this.barType,
        symbol: symbol ?? this.symbol,
        barDateFrom: barDateFrom ?? this.barDateFrom,
        barDateTo: barDateTo ?? this.barDateTo,
        sortAsc: sortAsc ?? this.sortAsc,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'size': size,
        'barType': barType,
        'symbol': symbol,
        if (barDateFrom != null && barDateFrom!.isNotEmpty) 'barDateFrom': barDateFrom,
        if (barDateTo != null && barDateTo!.isNotEmpty) 'barDateTo': barDateTo,
        if (sortAsc != null) 'sortAsc': sortAsc,
      };
}

class BarData {
  final String symbol;
  final String barDateTime;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double closePrice;
  final double highProfit;
  final double lowProfit;
  final double closeProfit;
  final double rangeProfit;
  final double rsiValue;

  BarData({
    required this.symbol,
    required this.barDateTime,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.highProfit,
    required this.lowProfit,
    required this.closeProfit,
    required this.rangeProfit,
    required this.rsiValue,
  });

  factory BarData.fromJson(Map<String, dynamic> json) => BarData(
        symbol: json['symbol'] as String? ?? '',
        barDateTime: json['barDateTime'] as String? ?? '',
        openPrice: (json['openPrice'] as num?)?.toDouble() ?? 0,
        highPrice: (json['highPrice'] as num?)?.toDouble() ?? 0,
        lowPrice: (json['lowPrice'] as num?)?.toDouble() ?? 0,
        closePrice: (json['closePrice'] as num?)?.toDouble() ?? 0,
        highProfit: (json['highProfit'] as num?)?.toDouble() ?? 0,
        lowProfit: (json['lowProfit'] as num?)?.toDouble() ?? 0,
        closeProfit: (json['closeProfit'] as num?)?.toDouble() ?? 0,
        rangeProfit: (json['rangeProfit'] as num?)?.toDouble() ?? 0,
        rsiValue: (json['rsiValue'] as num?)?.toDouble() ?? 0,
      );
}

class BarDataSearchResponse {
  final int returnCode;
  final int totalCount;
  final int totalPage;
  final List<BarData> list;

  BarDataSearchResponse({
    required this.returnCode,
    required this.totalCount,
    required this.totalPage,
    required this.list,
  });

  factory BarDataSearchResponse.fromJson(Map<String, dynamic> json) =>
      BarDataSearchResponse(
        returnCode: json['returnCode'] as int? ?? 0,
        totalCount: json['totalCount'] as int? ?? 0,
        totalPage: json['totalPage'] as int? ?? 0,
        list: (json['list'] as List? ?? [])
            .map((e) => BarData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class BarDataImportResult {
  final String symbol;
  final String? fileName;
  final int? fileSize;
  final String? barDateTime;
  final String? resultStatus;
  final int? readCount;
  final int? existsCount;
  final int? insertCount;
  final int? differenceCount;
  final String? message;

  BarDataImportResult({
    required this.symbol,
    this.fileName,
    this.fileSize,
    this.barDateTime,
    this.resultStatus,
    this.readCount,
    this.existsCount,
    this.insertCount,
    this.differenceCount,
    this.message,
  });

  factory BarDataImportResult.fromJson(Map<String, dynamic> json) =>
      BarDataImportResult(
        symbol: json['symbol'] as String? ?? '',
        fileName: json['fileName'] as String?,
        fileSize: json['fileSize'] as int?,
        barDateTime: json['barDateTime'] as String?,
        resultStatus: json['resultStatus'] as String?,
        readCount: json['readCount'] as int?,
        existsCount: json['existsCount'] as int?,
        insertCount: json['insertCount'] as int?,
        differenceCount: json['differenceCount'] as int?,
        message: json['message'] as String?,
      );
}
