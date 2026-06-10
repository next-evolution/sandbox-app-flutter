class SymbolDto {
  final String symbol;
  final String symbolType;
  final String name;
  final double validScale;
  final double targetVolatility;
  final double sortOrder;

  SymbolDto({
    required this.symbol,
    required this.symbolType,
    required this.name,
    required this.validScale,
    required this.targetVolatility,
    required this.sortOrder,
  });

  factory SymbolDto.fromJson(Map<String, dynamic> json) => SymbolDto(
        symbol: json['symbol'] as String,
        symbolType: json['symbolType'] as String,
        name: json['name'] as String,
        validScale: (json['validScale'] as num).toDouble(),
        targetVolatility: (json['targetVolatility'] as num).toDouble(),
        sortOrder: (json['sortOrder'] as num).toDouble(),
      );

  static SymbolDto get defaultSymbol => SymbolDto(
        symbol: 'USDJPY',
        symbolType: 'Trade',
        name: 'USDJPY',
        validScale: 3,
        targetVolatility: 0.5,
        sortOrder: 0,
      );
}
