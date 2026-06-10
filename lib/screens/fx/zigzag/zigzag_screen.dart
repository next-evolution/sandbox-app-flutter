import 'package:flutter/material.dart';
import '../../../models/symbol_dto.dart';
import '../../../models/zigzag.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/search_pager.dart';
import 'widgets/chart_modal.dart';

const _depths = [10, 12];
const _pageSizes = [50, 100, 200, 500];

final _dirOptions = [
  const _DirOpt(999, '─'),
  const _DirOpt(1, '↑↑'),
  const _DirOpt(2, '↑'),
  const _DirOpt(0, '→'),
  const _DirOpt(-1, '↓'),
  const _DirOpt(-2, '↓↓'),
];

class _DirOpt {
  final int value;
  final String label;
  const _DirOpt(this.value, this.label);
}

String _pad2(int n) => n.toString().padLeft(2, '0');

String _tomorrow() {
  final d = DateTime.now().add(const Duration(days: 1));
  final offset = d.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final oh = _pad2(offset.inHours.abs());
  final om = _pad2(offset.inMinutes.abs() % 60);
  return '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}T00:00:00$sign$oh:$om';
}

ZigZagSearchRequest _defaultReq(String symbol) => ZigZagSearchRequest(
      page: 1,
      size: 100,
      barType: '4H',
      symbol: symbol,
      depth: 12,
      wave: 1,
      previousWave: 0,
      nextWave: 0,
      next2Wave: 0,
      direction4h200: 999,
      direction4h75: 999,
      direction4h20: 999,
      direction1h200: 999,
      direction15m200: 999,
      wave4h: 0,
      directionTarget4h200: 999,
      barDateTimeMin: '2002-01-01T00:00:00+09:00',
      barDateTimeMax: _tomorrow(),
    );

class ZigZagScreen extends StatefulWidget {
  const ZigZagScreen({super.key});

  @override
  State<ZigZagScreen> createState() => _ZigZagScreenState();
}

class _ZigZagScreenState extends State<ZigZagScreen> {
  final _api = ApiService();
  List<SymbolDto> _symbolList = [];
  SymbolDto? _symbol;
  ZigZagSearchRequest _req = _defaultReq('USDJPY');
  ZigZagSearchResponse _res =
      ZigZagSearchResponse(totalCount: 0, totalPage: 0, list: []);
  bool _isLoading = false;
  String? _errorMsg;
  bool _showFilter = true;
  int? _modalIndex;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final raw = await _api.getList('/v1/fx/symbol/currency-pair-list');
      final symbols =
          raw.map((e) => SymbolDto.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      final first = symbols.isNotEmpty ? symbols[0] : null;
      setState(() {
        _symbolList = symbols;
        _symbol = first;
      });
      if (first != null) {
        final req = _defaultReq(first.symbol);
        await _search(req);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _search(ZigZagSearchRequest req) async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      _symbol = _symbolList.firstWhere((s) => s.symbol == req.symbol,
          orElse: () => _symbolList.first);
      final json = await _api.post('/v1/fx/zigzag', req.toJson());
      final res = ZigZagSearchResponse.fromJson(json);
      if (!mounted) return;
      setState(() {
        _res = res;
        _req = req;
        _showFilter = true;
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
    final scale = _symbol?.validScale.toInt() ?? 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FX Indicator',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('ZigZag',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/fx/zigzag/generate'),
            child: const Text('Generate',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Text(_errorMsg!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTable(scale),
              ),
            ],
          ),
          if (_modalIndex != null)
            ChartModal(
              dataList: _res.list,
              initialIndex: _modalIndex!,
              scale: scale,
              onClose: () => setState(() => _modalIndex = null),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Depth:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            DropdownButton<int>(
              value: _req.depth,
              isDense: true,
              dropdownColor: AppColors.surfaceVariant,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              underline: const SizedBox(),
              items: _depths
                  .map((d) =>
                      DropdownMenuItem(value: d, child: Text('$d')))
                  .toList(),
              onChanged: (v) {
                if (v != null) _search(_req.copyWith(depth: v, page: 1));
              },
            ),
            const SizedBox(width: 12),
            if (_symbolList.isNotEmpty)
              DropdownButton<String>(
                value: _req.symbol,
                isDense: true,
                dropdownColor: AppColors.surfaceVariant,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                underline: const SizedBox(),
                items: _symbolList
                    .map((s) =>
                        DropdownMenuItem(value: s.symbol, child: Text(s.symbol)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _search(_req.copyWith(symbol: v, page: 1));
                },
              ),
            const SizedBox(width: 16),
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
      ),
    );
  }

  Widget _buildTable(int scale) {
    final wave = _req.wave;
    int up = 0, dw = 0;
    for (final v in _res.list) {
      if (wave > 0) {
        if (v.next.wave > v.current.wave && v.next2.wave > v.next.wave) {
          up++;
        } else {
          dw++;
        }
      } else {
        if (v.next.wave < v.current.wave && v.next2.wave < v.next.wave) {
          dw++;
        } else {
          up++;
        }
      }
    }
    final all = _res.list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showFilter) _buildFilterRow(up, dw, all),
        Expanded(
          child: _res.list.isEmpty
              ? const Center(
                  child: Text('データがありません',
                      style: TextStyle(color: AppColors.textSecondary)))
              : _buildScrollableTable(scale),
        ),
      ],
    );
  }

  Widget _buildFilterRow(int up, int dw, int all) {
    final wave = _req.wave;
    final allColor = wave > 0 ? AppColors.fxBuyLg : AppColors.fxSellLg;
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.expand_more,
                  size: 16, color: AppColors.textSecondary),
              onPressed: () => setState(() => _showFilter = false),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text('ALL: ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            Text('$all',
                style: TextStyle(
                    color: allColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            const Text('UP: ',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            Text('$up',
                style: const TextStyle(
                    color: AppColors.fxBuyLg,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            if (all > 0 && up > 0) ...[
              const SizedBox(width: 4),
              Text('(${(up / all).toStringAsFixed(1)})',
                  style: const TextStyle(
                      color: AppColors.fxBuy, fontSize: 11)),
            ],
            const SizedBox(width: 12),
            const Text('DW: ',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            Text('$dw',
                style: const TextStyle(
                    color: AppColors.fxSellLg,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            if (all > 0 && dw > 0) ...[
              const SizedBox(width: 4),
              Text('(${(dw / all).toStringAsFixed(1)})',
                  style: const TextStyle(
                      color: AppColors.fxSell, fontSize: 11)),
            ],
            const SizedBox(width: 16),
            _waveInput('p', _req.previousWave,
                (v) => _search(_req.copyWith(previousWave: v, page: 1))),
            _waveInput('W', _req.wave,
                (v) => _search(_req.copyWith(wave: v, page: 1))),
            _waveInput('n', _req.nextWave,
                (v) => _search(_req.copyWith(nextWave: v, page: 1))),
            _waveInput('n2', _req.next2Wave,
                (v) => _search(_req.copyWith(next2Wave: v, page: 1))),
            const SizedBox(width: 8),
            _dirSelect(_req.direction4h200,
                (v) => _search(_req.copyWith(direction4h200: v, page: 1))),
            const SizedBox(width: 8),
            _waveInput('4H', _req.wave4h,
                (v) => _search(_req.copyWith(wave4h: v, page: 1))),
            const SizedBox(width: 4),
            _dirSelect(_req.directionTarget4h200,
                (v) => _search(_req.copyWith(directionTarget4h200: v, page: 1))),
          ],
        ),
      ),
    );
  }

  Widget _waveInput(String label, int value, void Function(int) onChange) {
    final ctrl = TextEditingController(text: '$value');
    return SizedBox(
      width: 48,
      child: TextField(
        controller: ctrl,
        keyboardType:
            const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        onSubmitted: (v) {
          final n = int.tryParse(v);
          if (n != null) onChange(n);
        },
      ),
    );
  }

  Widget _dirSelect(int value, void Function(int) onChange) =>
      DropdownButton<int>(
        value: value,
        isDense: true,
        dropdownColor: AppColors.surfaceVariant,
        style:
            const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        underline: const SizedBox(),
        items: _dirOptions
            .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChange(v);
        },
      );

  Widget _buildScrollableTable(int scale) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showFilter)
              Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  icon: const Icon(Icons.expand_less,
                      size: 16, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _showFilter = true),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            _buildHeader(),
            ..._res.list.asMap().entries.map((e) => _buildDataRow(
                e.key, e.value, scale)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Row(
        children: [
          _hCell('begin~end', 156),
          _hCell('R', 76),
          _hCell('S', 76),
          _hCell('p', 36),
          _hCell('W', 36),
          _hCell('n', 36),
          _hCell('n2', 36),
          _hCell('Range', 60),
          _hCell('4H200', 56),
          _hCell('DXY4h', 40),
          _hCell('DXY1h', 40),
          _hCell('NextRs', 52),
          _hCell('NextMax', 64),
          _hCell('4H', 40),
          _hCell('4H200', 56),
        ],
      ),
    );
  }

  Widget _hCell(String label, double width) => SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10),
              overflow: TextOverflow.ellipsis),
        ),
      );

  Widget _buildDataRow(int index, ZigZagResult r, int scale) {
    final startDt = _fmtDt(r.current.waveStart);
    final endDt = _fmtDt(r.current.waveEnd);
    final isUsd = r.symbol.endsWith('USD');
    final priceRange = isUsd
        ? r.current.fibonacci.priceRange * 100
        : r.current.fibonacci.priceRange;
    final rangeStr = priceRange.toStringAsFixed(3);

    return GestureDetector(
      onDoubleTap: () => setState(() => _modalIndex = index),
      child: Container(
        decoration: BoxDecoration(
          border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5)),
          color: index % 2 == 0
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 156,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 5, horizontal: 4),
                child: Text(
                    '${startDt[0]} ${startDt[1]} ~ ${endDt[0]} ${endDt[1]}',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 10)),
              ),
            ),
            _priceCell(r.current.resistance.toStringAsFixed(scale), 76,
                AppColors.cellResistance),
            _priceCell(r.current.support.toStringAsFixed(scale), 76,
                AppColors.cellSupport),
            _waveCell(r.previous.wave, 36, false),
            _waveCell(r.current.wave, 36, true),
            _waveCell(r.next.wave, 36, false),
            _waveCell(r.next2.wave, 36, true),
            SizedBox(
              width: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(rangeStr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: AppColors.fxBuy, fontSize: 11)),
              ),
            ),
            _smaCell(r.current.sma4h200s, 56),
            _waveCell(r.waveDxy4h.toInt(), 40, false),
            _waveCell(r.waveDxy1h.toInt(), 40, false),
            _numCell(
                r.nextRsRate != 0
                    ? r.nextRsRate.toStringAsFixed(1)
                    : '-',
                52),
            _numCell(
                r.next2MaxRate != 0
                    ? r.next2MaxRate.toStringAsFixed(3)
                    : '-',
                64),
            _waveCell(r.target4h.wave, 40, true),
            _smaCell(r.target4h.sma4h200s, 56),
          ],
        ),
      ),
    );
  }

  Widget _priceCell(String val, double width, Color color) => SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: Text(val,
              style: TextStyle(color: color, fontSize: 11)),
        ),
      );

  Widget _waveCell(int wave, double width, bool large) {
    final color = wave > 0
        ? (large ? AppColors.fxBuyLg : AppColors.fxBuy)
        : (large ? AppColors.fxSellLg : AppColors.fxSell);
    final bg = wave > 0 ? AppColors.zzBgUp : AppColors.zzBgDw;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      color: bg,
      child: Text(' $wave',
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: large ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _smaCell(Sma sma, double width) {
    Color bg;
    switch (sma.direction) {
      case 1:
        bg = AppColors.zzSmaUp;
        break;
      case 2:
        bg = AppColors.zzSmaUpS;
        break;
      case -1:
        bg = AppColors.zzSmaDw;
        break;
      case -2:
        bg = AppColors.zzSmaDwS;
        break;
      default:
        bg = AppColors.zzSmaFlat;
    }
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      color: bg.withValues(alpha: 0.4),
      child: Text(
          'F${sma.fibonacci.toStringAsFixed(1)}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }

  Widget _numCell(String val, double width) => SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: Text(val,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 11)),
        ),
      );

  List<String> _fmtDt(String dt) {
    final sep = dt.contains('T') ? 'T' : ' ';
    final parts = dt.split(sep);
    final date = parts[0];
    final time = parts.length > 1 ? parts[1] : '';
    return [
      date.length >= 8 ? date.substring(date.length - 8) : date,
      time.length >= 5 ? time.substring(0, 5) : time,
    ];
  }
}
