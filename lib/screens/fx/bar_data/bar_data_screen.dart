import 'package:flutter/material.dart';
import '../../../models/bar_data.dart';
import '../../../models/symbol_dto.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/search_pager.dart';

// label → API value
const _barTypesTrade = [
  ('M15', '15M'),
  ('H1', '1H'),
  ('H4', '4H'),
  ('D1', '1D'),
];
const _barTypesAnalyze = [
  ('H1', '1H'),
  ('H4', '4H'),
  ('D1', '1D'),
];
const _pageSizes = [50, 100, 200, 500];
const _days = ['日', '月', '火', '水', '木', '金', '土'];

class BarDataScreen extends StatefulWidget {
  final String symbolType;

  const BarDataScreen({super.key, required this.symbolType});

  @override
  State<BarDataScreen> createState() => _BarDataScreenState();
}

class _BarDataScreenState extends State<BarDataScreen> {
  final _api = ApiService();
  List<SymbolDto> _symbolList = [];
  BarDataSearchResponse _res =
      BarDataSearchResponse(returnCode: 0, totalCount: 0, totalPage: 0, list: []);
  late BarDataSearchRequest _req;
  bool _isLoading = false;
  String? _errorMsg;
  final _dateFromCtrl = TextEditingController();
  final _dateToCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _req = BarDataSearchRequest(
      page: 1,
      size: 100,
      barType: '1H',
      symbol: '',
      sortAsc: false,
    );
    _init();
  }

  @override
  void dispose() {
    _dateFromCtrl.dispose();
    _dateToCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = widget.symbolType == 'Analyze'
          ? '/v1/fx/symbol/currency-index-list'
          : '/v1/fx/symbol/currency-pair-list';
      final list = await _api.getList(endpoint);
      final symbols =
          list.map((e) => SymbolDto.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      if (symbols.isEmpty) {
        setState(() {
          _symbolList = [];
          _isLoading = false;
        });
        return;
      }
      final firstReq = _req.copyWith(symbol: symbols[0].symbol);
      setState(() {
        _symbolList = symbols;
        _req = firstReq;
      });
      await _search(firstReq);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _search(BarDataSearchRequest req) async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final json = await _api.post('/v1/fx/bar-data', req.toJson());
      final res = BarDataSearchResponse.fromJson(json);
      if (!mounted) return;
      setState(() {
        _res = res;
        _req = req;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbolType = widget.symbolType;
    final title = symbolType == 'Trade' ? 'BarData (FX)' : 'BarData (INDEX)';
    final selectedSymbol = _symbolList.isNotEmpty
        ? _symbolList.firstWhere((s) => s.symbol == _req.symbol,
            orElse: () => _symbolList.first)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FX barData',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControls(),
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(_errorMsg!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTable(selectedSymbol),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (widget.symbolType == 'Analyze'
                      ? _barTypesAnalyze
                      : _barTypesTrade)
                  .map((entry) {
                final label = entry.$1;
                final apiVal = entry.$2;
                final active = _req.barType == apiVal;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          active ? AppColors.primary.withValues(alpha: 0.2) : null,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      if (!active) _search(_req.copyWith(barType: apiVal, page: 1));
                    },
                    child: Text(label,
                        style: TextStyle(
                          color: active ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 13,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_symbolList.isNotEmpty) ...[
                  const Text('通貨ペア:',
                      style:
                          TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 4),
                  DropdownButton<String>(
                    value: _req.symbol.isNotEmpty ? _req.symbol : null,
                    isDense: true,
                    dropdownColor: AppColors.surfaceVariant,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    underline: const SizedBox(),
                    items: _symbolList
                        .map((s) =>
                            DropdownMenuItem(value: s.symbol, child: Text(s.symbol)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _search(_req.copyWith(symbol: v, page: 1));
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                Row(
                  children: [
                    Checkbox(
                      value: _req.sortAsc ?? false,
                      onChanged: (v) => _search(_req.copyWith(sortAsc: v, page: 1)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text('ASC',
                        style:
                            TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 12),
                const Text('期間:',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 4),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _dateFromCtrl,
                    decoration: const InputDecoration(
                      hintText: 'YYYYMMDD',
                      hintStyle:
                          TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    ),
                    style:
                        const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('〜',
                      style:
                          TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _dateToCtrl,
                    decoration: const InputDecoration(
                      hintText: 'YYYYMMDD',
                      hintStyle:
                          TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    ),
                    style:
                        const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  onPressed: () => _search(_req.copyWith(
                    page: 1,
                    barDateFrom: _dateFromCtrl.text,
                    barDateTo: _dateToCtrl.text,
                  )),
                  child:
                      const Text('Search', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SearchPager(
            page: _req.page,
            totalPage: _res.totalPage,
            totalCount: _res.totalCount,
            size: _req.size,
            pageSizes: _pageSizes,
            onPageChange: (p) => _search(_req.copyWith(page: p)),
            onSizeChange: (s) => _search(_req.copyWith(size: s, page: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(SymbolDto? sym) {
    if (_res.list.isEmpty) {
      return const Center(
        child: Text('データがありません',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 32,
            dataRowMinHeight: 28,
            dataRowMaxHeight: 28,
            columnSpacing: 12,
            headingTextStyle:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            columns: const [
            DataColumn(label: Text('BarTime')),
            DataColumn(label: Text('Range'), numeric: true),
            DataColumn(label: Text('Close'), numeric: true),
            DataColumn(label: Text('High'), numeric: true),
            DataColumn(label: Text('Low'), numeric: true),
            DataColumn(label: Text('RSI'), numeric: true),
            DataColumn(label: Text('Open'), numeric: true),
            DataColumn(label: Text('High'), numeric: true),
            DataColumn(label: Text('Low'), numeric: true),
            DataColumn(label: Text('Close'), numeric: true),
          ],
          rows: _res.list.map((row) {
            final scale = sym?.validScale.toInt() ?? 3;
            return DataRow(cells: [
              DataCell(Text(_formatBarTime(row.barDateTime),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 11))),
              DataCell(_pipCell(row.rangeProfit, sym)),
              DataCell(_pipCell(row.closeProfit, sym)),
              DataCell(_pipCell(row.highProfit, sym)),
              DataCell(_pipCell(row.lowProfit, sym)),
              DataCell(_rsiCell(row.rsiValue)),
              DataCell(Text(row.openPrice.toStringAsFixed(scale),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 11))),
              DataCell(Text(row.highPrice.toStringAsFixed(scale),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 11))),
              DataCell(Text(row.lowPrice.toStringAsFixed(scale),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 11))),
              DataCell(Text(row.closePrice.toStringAsFixed(scale),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 11))),
            ]);
          }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _pipCell(double raw, SymbolDto? sym) {
    if (sym == null) {
      return Text(raw.toStringAsFixed(1),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 11));
    }
    final pips = sym.symbol.endsWith('USD') ? raw * 100000 : raw * 1000;
    Color color;
    bool bold = false;
    if (pips >= sym.targetVolatility) {
      color = AppColors.fxBuyLg;
      bold = true;
    } else if (pips > 0) {
      color = AppColors.fxBuy;
    } else if (pips <= -sym.targetVolatility) {
      color = AppColors.fxSellLg;
      bold = true;
    } else {
      color = AppColors.fxSell;
    }
    return Text(
      pips.toStringAsFixed(1),
      style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _rsiCell(double rsi) {
    Color color;
    bool bold = false;
    if (rsi >= 70) {
      color = AppColors.fxBuyLg;
      bold = true;
    } else if (rsi >= 50) {
      color = AppColors.fxBuy;
    } else if (rsi <= 30) {
      color = AppColors.fxSellLg;
      bold = true;
    } else {
      color = AppColors.fxSell;
    }
    return Text(
      rsi.toStringAsFixed(2),
      style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    );
  }

  String _formatBarTime(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      final hh = d.hour.toString().padLeft(2, '0');
      final min = d.minute.toString().padLeft(2, '0');
      final day = _days[d.weekday % 7];
      return '${d.year}/$mm/$dd $hh:$min ($day)';
    } catch (_) {
      return dt;
    }
  }
}
