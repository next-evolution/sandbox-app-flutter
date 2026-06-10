class EconomicIndicatorData {
  final int id;
  final String countryCode;
  final String? countryNameShort;
  final String name;
  final String importance;
  final String publication;
  final String publicationDate;
  final String publicationTime;
  final int dayOfWeek;
  final String? subTitle;
  final String resultValue;
  final String? forecastValue;
  final String? previousValue;
  final String? unitOfValue;
  final String? memo;

  EconomicIndicatorData({
    required this.id,
    required this.countryCode,
    this.countryNameShort,
    required this.name,
    required this.importance,
    required this.publication,
    required this.publicationDate,
    required this.publicationTime,
    required this.dayOfWeek,
    this.subTitle,
    required this.resultValue,
    this.forecastValue,
    this.previousValue,
    this.unitOfValue,
    this.memo,
  });

  factory EconomicIndicatorData.fromJson(Map<String, dynamic> json) =>
      EconomicIndicatorData(
        id: json['id'] as int? ?? 0,
        countryCode: json['countryCode'] as String? ?? '',
        countryNameShort: json['countryNameShort'] as String?,
        name: json['name'] as String? ?? '',
        importance: json['importance'] as String? ?? '',
        publication: json['publication'] as String? ?? '',
        publicationDate: json['publicationDate'] as String? ?? '',
        publicationTime: json['publicationTime'] as String? ?? '',
        dayOfWeek: json['dayOfWeek'] as int? ?? 0,
        subTitle: json['subTitle'] as String?,
        resultValue: json['resultValue'] as String? ?? '-',
        forecastValue: json['forecastValue'] as String?,
        previousValue: json['previousValue'] as String?,
        unitOfValue: json['unitOfValue'] as String?,
        memo: json['memo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'countryCode': countryCode,
        'name': name,
        'importance': importance,
        'publication': publication,
        'publicationDate': publicationDate,
        'publicationTime': publicationTime,
        'dayOfWeek': dayOfWeek,
        if (subTitle != null && subTitle!.isNotEmpty) 'subTitle': subTitle,
        'resultValue': resultValue,
        if (forecastValue != null && forecastValue!.isNotEmpty) 'forecastValue': forecastValue,
        if (previousValue != null && previousValue!.isNotEmpty) 'previousValue': previousValue,
        if (memo != null && memo!.isNotEmpty) 'memo': memo,
      };
}

class EIDSearchRequest {
  final int page;
  final int size;
  final bool sortAsc;
  final String? publicationBaseDate;
  final String? importance;
  final String? countryCode;
  final int? id;

  EIDSearchRequest({
    required this.page,
    required this.size,
    required this.sortAsc,
    this.publicationBaseDate,
    this.importance,
    this.countryCode,
    this.id,
  });

  EIDSearchRequest copyWith({
    int? page,
    int? size,
    bool? sortAsc,
    String? publicationBaseDate,
    String? importance,
    String? countryCode,
    int? id,
    bool clearCountryCode = false,
    bool clearId = false,
    bool clearPublicationBaseDate = false,
    bool clearImportance = false,
  }) =>
      EIDSearchRequest(
        page: page ?? this.page,
        size: size ?? this.size,
        sortAsc: sortAsc ?? this.sortAsc,
        publicationBaseDate:
            clearPublicationBaseDate ? null : (publicationBaseDate ?? this.publicationBaseDate),
        importance: clearImportance ? null : (importance ?? this.importance),
        countryCode: clearCountryCode ? null : (countryCode ?? this.countryCode),
        id: clearId ? null : (id ?? this.id),
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'size': size,
        'sortAsc': sortAsc,
        if (publicationBaseDate != null && publicationBaseDate!.isNotEmpty)
          'publicationBaseDate': publicationBaseDate,
        if (importance != null && importance!.isNotEmpty) 'importance': importance,
        if (countryCode != null && countryCode!.isNotEmpty) 'countryCode': countryCode,
        if (id != null) 'id': id,
      };
}

class EIDSearchResponse {
  final int totalCount;
  final int totalPage;
  final List<EconomicIndicatorData> list;

  EIDSearchResponse({
    required this.totalCount,
    required this.totalPage,
    required this.list,
  });

  factory EIDSearchResponse.fromJson(Map<String, dynamic> json) => EIDSearchResponse(
        totalCount: json['totalCount'] as int? ?? 0,
        totalPage: json['totalPage'] as int? ?? 0,
        list: (json['list'] as List? ?? [])
            .map((e) => EconomicIndicatorData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TextImportResult {
  final String fileName;
  final int fileSize;
  final String? resultStatus;
  final int readCount;
  final String? message;

  TextImportResult({
    required this.fileName,
    required this.fileSize,
    this.resultStatus,
    required this.readCount,
    this.message,
  });

  factory TextImportResult.fromJson(Map<String, dynamic> json) => TextImportResult(
        fileName: json['fileName'] as String? ?? '',
        fileSize: json['fileSize'] as int? ?? 0,
        resultStatus: json['resultStatus'] as String?,
        readCount: json['readCount'] as int? ?? 0,
        message: json['message'] as String?,
      );
}
