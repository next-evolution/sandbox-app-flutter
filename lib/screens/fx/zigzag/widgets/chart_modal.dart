import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/zigzag.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';

const _barTabs = [
  _BarTab('15M', 'M15'),
  _BarTab('1H', 'H1'),
  _BarTab('4H', 'H4'),
];

class _BarTab {
  final String label;
  final String value;
  const _BarTab(this.label, this.value);
}

class ChartModal extends StatefulWidget {
  final List<ZigZagResult> dataList;
  final int initialIndex;
  final int scale;
  final VoidCallback onClose;

  const ChartModal({
    super.key,
    required this.dataList,
    required this.initialIndex,
    required this.scale,
    required this.onClose,
  });

  @override
  State<ChartModal> createState() => _ChartModalState();
}

class _ChartModalState extends State<ChartModal> {
  final _api = ApiService();
  late int _index;
  String _barType = 'H4';
  List<ZigZagBarData> _barData = [];
  bool _isLoading = false;
  String? _toastMsg;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _load();
  }

  Future<void> _load() async {
    final result = widget.dataList[_index];
    setState(() {
      _isLoading = true;
      _barData = [];
    });
    try {
      final json = await _api.post('/v1/fx/zigzag/bar-data', {
        'barType': _barType,
        'symbol': result.symbol,
        'depth': result.depth,
        'waveStart': result.current.waveStart,
        'wave': result.current.wave,
      });
      final list = (json['zigZagBarDataList'] as List? ?? [])
          .map((e) => ZigZagBarData.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _barData = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _toastMsg = e.toString();
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _toastMsg = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.dataList[_index];
    final cur = result.current;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black54,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height * 0.88,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2533),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  children: [
                    _buildTitleBar(result, cur),
                    _buildTabAndInfo(result, cur),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _barData.isEmpty
                              ? const Center(
                                  child: Text('データがありません',
                                      style: TextStyle(
                                          color: AppColors.textSecondary)))
                              : Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _CandlestickChart(
                                    data: _barData,
                                    waveStart: cur.waveStart,
                                    scale: widget.scale,
                                    resistance: cur.resistance,
                                    support: cur.support,
                                  ),
                                ),
                    ),
                    if (_toastMsg != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_toastMsg!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(ZigZagResult result, ZigZagInfoSma cur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${result.symbol}  depth:${result.depth}  wave:${cur.wave}',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabAndInfo(ZigZagResult result, ZigZagInfoSma cur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Row(
            children: _barTabs.map((tab) {
              final active = _barType == tab.value;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: active
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : null,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    if (!active) {
                      setState(() => _barType = tab.value);
                      _load();
                    }
                  },
                  child: Text(tab.label,
                      style: TextStyle(
                          color: active
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 12)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildMiniInfo(result, cur)),
          Column(
            children: [
              _navBtn(Icons.keyboard_arrow_up, _index > 0, () {
                setState(() => _index--);
                _load();
              }),
              Text('${_index + 1}/${widget.dataList.length}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
              _navBtn(Icons.keyboard_arrow_down,
                  _index < widget.dataList.length - 1, () {
                setState(() => _index++);
                _load();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, bool enabled, VoidCallback onTap) =>
      InkWell(
        onTap: enabled ? onTap : null,
        child: Icon(icon,
            size: 20,
            color: enabled ? AppColors.textPrimary : AppColors.border),
      );

  Widget _buildMiniInfo(ZigZagResult result, ZigZagInfoSma cur) {
    final scale = widget.scale;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _infoChip('R', cur.resistance.toStringAsFixed(scale),
              AppColors.cellResistance),
          const SizedBox(width: 8),
          _infoChip(
              'S', cur.support.toStringAsFixed(scale), AppColors.cellSupport),
          const SizedBox(width: 8),
          _waveChip('wave', cur.wave),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('$label: $value',
            style: TextStyle(color: color, fontSize: 11)),
      );

  Widget _waveChip(String label, int wave) {
    final color = wave > 0 ? AppColors.fxBuy : AppColors.fxSell;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (wave > 0 ? AppColors.zzBgUp : AppColors.zzBgDw),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label: $wave',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _CandlestickChart extends StatelessWidget {
  final List<ZigZagBarData> data;
  final String waveStart;
  final int scale;
  final double resistance;
  final double support;

  const _CandlestickChart({
    required this.data,
    required this.waveStart,
    required this.scale,
    required this.resistance,
    required this.support,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(
        data: data,
        waveStart: waveStart,
        scale: scale,
        resistance: resistance,
        support: support,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<ZigZagBarData> data;
  final String waveStart;
  final int scale;
  final double resistance;
  final double support;

  _ChartPainter({
    required this.data,
    required this.waveStart,
    required this.scale,
    required this.resistance,
    required this.support,
  });

  static const _padTop = 20.0;
  static const _padRight = 16.0;
  static const _padBottom = 36.0;
  static const _padLeft = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final plotW = size.width - _padLeft - _padRight;
    final plotH = size.height - _padTop - _padBottom;

    final allPrices = data.expand((d) => [d.highPrice, d.lowPrice]).toList()
      ..addAll([resistance, support]);
    final minP = allPrices.reduce(math.min);
    final maxP = allPrices.reduce(math.max);
    final priceRange = maxP - minP;
    final minPad = minP - priceRange * 0.05;
    final maxPad = maxP + priceRange * 0.05;
    final paddedRange = maxPad - minPad;

    double toY(double price) =>
        _padTop + plotH * (1 - (price - minPad) / paddedRange);
    final barW = plotW / data.length;
    double toX(int i) => _padLeft + (i + 0.5) * barW;

    // Build dt→x map for waveStart line
    final dtToX = <String, double>{};
    for (var i = 0; i < data.length; i++) {
      final key = data[i].barDateTime.replaceFirst('T', ' ').substring(0, 16);
      dtToX[key] = toX(i);
    }

    // Grid + Y labels
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(
        color: Colors.white.withValues(alpha: 0.4), fontSize: 9);

    const yCount = 6;
    for (var i = 0; i <= yCount; i++) {
      final price = minPad + paddedRange / yCount * i;
      final y = toY(price);
      canvas.drawLine(
          Offset(_padLeft, y), Offset(size.width - _padRight, y), gridPaint);
      _drawText(canvas, price.toStringAsFixed(scale), Offset(_padLeft - 4, y),
          labelStyle, TextAlign.right);
    }

    // X labels
    final xLabelStep = math.max(1, (data.length / 10).ceil());
    final xLabelStyle = TextStyle(
        color: Colors.white.withValues(alpha: 0.35), fontSize: 9);
    for (var i = 0; i < data.length; i += xLabelStep) {
      final x = toX(i);
      canvas.drawLine(Offset(x, _padTop), Offset(x, _padTop + plotH), gridPaint);
      final dt = data[i].barDateTime.replaceFirst('T', ' ');
      final label = dt.length >= 16 ? dt.substring(5, 16) : dt;
      _drawText(canvas, label,
          Offset(x, size.height - _padBottom + 4), xLabelStyle, TextAlign.center);
    }

    // WaveStart vertical line
    final wsKey = waveStart.replaceFirst('T', ' ');
    final wsKeyShort = wsKey.length >= 16 ? wsKey.substring(0, 16) : wsKey;
    final wsX = dtToX[wsKeyShort];
    if (wsX != null) {
      final wsPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.7)
        ..strokeWidth = 1;
      _drawDashedLine(canvas, Offset(wsX, _padTop),
          Offset(wsX, _padTop + plotH), wsPaint, [4, 3]);
    }

    // Resistance / Support lines
    _drawHLine(canvas, size, toY, resistance,
        const Color(0xFFF87171), 0.9, [6, 3], 'R');
    _drawHLine(canvas, size, toY, support,
        const Color(0xFF60A5FA), 0.9, [6, 3], 'S');

    // SMA paths
    _drawSmaPath(canvas, data, (d) => d.sma200, toX, toY,
        Colors.white, 2, 0.85);
    _drawSmaPath(canvas, data, (d) => d.sma75, toX, toY,
        const Color(0xFFFBBF24), 1, 0.75);
    _drawSmaPath(canvas, data, (d) => d.sma20, toX, toY,
        const Color(0xFF7DD3FC), 1, 0.75);

    // Candlesticks
    final candleW = math.max(1.0, barW * 0.65);
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final x = toX(i);
      final isUp = d.closePrice >= d.openPrice;
      final color =
          isUp ? const Color(0xFF3B82F6) : const Color(0xFFF87171);
      final candlePaint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..strokeWidth = 1;
      // Wick
      canvas.drawLine(
          Offset(x, toY(d.highPrice)), Offset(x, toY(d.lowPrice)), candlePaint);
      // Body
      final bodyTop = toY(math.max(d.openPrice, d.closePrice));
      final bodyBottom = toY(math.min(d.openPrice, d.closePrice));
      final bodyH = math.max(1.0, bodyBottom - bodyTop);
      canvas.drawRect(
        Rect.fromLTWH(x - candleW / 2, bodyTop, candleW, bodyH),
        candlePaint,
      );
    }

    // SMA legend
    _drawLegend(canvas, _padLeft + 2, _padTop + 6, Colors.white, 'SMA200');
    _drawLegend(
        canvas, _padLeft + 68, _padTop + 6, const Color(0xFFFBBF24), 'SMA75');
    _drawLegend(
        canvas, _padLeft + 130, _padTop + 6, const Color(0xFF7DD3FC), 'SMA20');
  }

  void _drawHLine(
    Canvas canvas,
    Size size,
    double Function(double) toY,
    double price,
    Color color,
    double opacity,
    List<double> dash,
    String label,
  ) {
    final y = toY(price);
    if (y < _padTop || y > _padTop + size.height - _padTop - _padBottom) return;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.2;
    _drawDashedLine(
        canvas, Offset(_padLeft, y), Offset(size.width - _padRight, y), paint, dash);
    _drawText(
        canvas,
        '$label ${price.toStringAsFixed(scale)}',
        Offset(size.width - _padRight - 3, y - 12),
        TextStyle(color: color.withValues(alpha: opacity), fontSize: 9),
        TextAlign.right);
  }

  void _drawSmaPath(
    Canvas canvas,
    List<ZigZagBarData> data,
    double Function(ZigZagBarData) getValue,
    double Function(int) toX,
    double Function(double) toY,
    Color color,
    double strokeWidth,
    double opacity,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path();
    bool moved = false;
    for (var i = 0; i < data.length; i++) {
      final v = getValue(data[i]);
      if (v > 0) {
        final x = toX(i);
        final y = toY(v);
        if (!moved) {
          path.moveTo(x, y);
          moved = true;
        } else {
          path.lineTo(x, y);
        }
      } else {
        moved = false;
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint, List<double> dash) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final dashLen = dash[0];
    final gapLen = dash[1];
    var pos = 0.0;
    while (pos < dist) {
      final endPos = math.min(pos + dashLen, dist);
      canvas.drawLine(
        Offset(start.dx + dx * pos / dist, start.dy + dy * pos / dist),
        Offset(start.dx + dx * endPos / dist, start.dy + dy * endPos / dist),
        paint,
      );
      pos += dashLen + gapLen;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset,
      TextStyle style, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    double dx = offset.dx;
    if (align == TextAlign.right) dx -= tp.width;
    if (align == TextAlign.center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, offset.dy - tp.height / 2));
  }

  void _drawLegend(Canvas canvas, double x, double y, Color color, String label) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x, y + 1), Offset(x + 10, y + 1), paint);
    _drawText(
        canvas,
        label,
        Offset(x + 14, y + 1),
        TextStyle(color: color, fontSize: 9),
        TextAlign.left);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.data != data || old._barType != _barType;

  String get _barType => '';
}
