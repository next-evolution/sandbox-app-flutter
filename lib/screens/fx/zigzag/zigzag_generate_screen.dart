import 'package:flutter/material.dart';
import '../../../models/zigzag.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_drawer.dart';

const _depths = [10, 12];
const _loadSizes = [1000, 5000, 10000];
const _barTypes = ['15M', '1H', '4H', '1D'];
const _symbolTypes = ['Trade', 'Analyze'];

class ZigZagGenerateScreen extends StatefulWidget {
  const ZigZagGenerateScreen({super.key});

  @override
  State<ZigZagGenerateScreen> createState() => _ZigZagGenerateScreenState();
}

class _ZigZagGenerateScreenState extends State<ZigZagGenerateScreen> {
  final _api = ApiService();
  List<ZigZagStatus> _statusList = [];
  bool _isLoading = false;
  String? _errorMsg;
  String? _toastMsg;
  bool _toastError = false;

  ZigZagGenerateRequest _req = const ZigZagGenerateRequest(
    symbol: '',
    symbolType: 'Trade',
    barType: '15M',
    depth: 12,
    barDateTime: '',
    loadSize: 1000,
  );

  @override
  void initState() {
    super.initState();
    _fetchStatus(_req);
  }

  String _getBaseDate(List<ZigZagStatus> list) {
    if (list.isEmpty) return '';
    return list.fold(list[0].barDateTimeMaxZigZag, (min, s) {
      return s.barDateTimeMaxZigZag.compareTo(min) < 0
          ? s.barDateTimeMaxZigZag
          : min;
    });
  }

  Future<void> _fetchStatus(ZigZagGenerateRequest r) async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final json = await _api.post('/v1/fx/zigzag/status', {
        'symbolType': r.symbolType,
        'barType': r.barType,
        'depth': r.depth,
      });
      final list = (json['list'] as List)
          .map((e) => ZigZagStatus.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      final baseDate = _getBaseDate(list);
      setState(() {
        _statusList = list;
        _req = r.copyWith(barDateTime: baseDate);
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

  Future<void> _handleChange(ZigZagGenerateRequest next) async {
    final needsRefetch = next.barType != _req.barType ||
        next.depth != _req.depth ||
        next.symbolType != _req.symbolType;
    if (needsRefetch) {
      await _fetchStatus(next);
    } else {
      setState(() => _req = next);
    }
  }

  Future<void> _generate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        title: const Text('GenerateSMA?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Range: ${_req.barType}\nFrontDate: ${_req.barDateTime}',
          style: const TextStyle(
              color: AppColors.textSecondary, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final updated = List<ZigZagStatus>.from(_statusList);
    try {
      for (int i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(message: 'processing...');
        if (!mounted) return;
        setState(() => _statusList = List.from(updated));

        final json = await _api.post(
            '/v1/fx/zigzag/generate', _req.copyWith(symbol: updated[i].symbol).toJson());
        final res = ZigZagStatus.fromJson(
            json['status'] as Map<String, dynamic>);
        updated[i] = res;
        if (!mounted) return;
        setState(() => _statusList = List.from(updated));
      }
      if (!mounted) return;
      setState(() {
        _req = _req.copyWith(barDateTime: _getBaseDate(updated));
        _isLoading = false;
      });
      _showToast('generated', false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
      _showToast(e.toString(), true);
    }
  }

  void _showToast(String msg, bool isError) {
    setState(() {
      _toastMsg = msg;
      _toastError = isError;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FX Indicator',
                style:
                    TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('ZigZag Generate',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('← Search',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildControlRow(),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Text(_errorMsg!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
              Expanded(
                child: _isLoading && _statusList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTable(),
              ),
            ],
          ),
          if (_toastMsg != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: _toastError ? AppColors.error : AppColors.success,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Text(_toastMsg!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlRow() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Type:',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            DropdownButton<String>(
              value: _req.barType,
              isDense: true,
              dropdownColor: AppColors.surfaceVariant,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
              underline: const SizedBox(),
              items: _barTypes
                  .map((bt) => DropdownMenuItem(value: bt, child: Text(bt)))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (v) {
                      if (v != null) _handleChange(_req.copyWith(barType: v));
                    },
            ),
            const SizedBox(width: 12),
            const Text('Depth:',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            DropdownButton<int>(
              value: _req.depth,
              isDense: true,
              dropdownColor: AppColors.surfaceVariant,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
              underline: const SizedBox(),
              items: _depths
                  .map((d) =>
                      DropdownMenuItem(value: d, child: Text('$d')))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (v) {
                      if (v != null) _handleChange(_req.copyWith(depth: v));
                    },
            ),
            const SizedBox(width: 12),
            const Text('SymbolType:',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            DropdownButton<String>(
              value: _req.symbolType,
              isDense: true,
              dropdownColor: AppColors.surfaceVariant,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
              underline: const SizedBox(),
              items: _symbolTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (v) {
                      if (v != null) {
                        _handleChange(_req.copyWith(symbolType: v));
                      }
                    },
            ),
            const SizedBox(width: 12),
            const Text('BarDateTime:',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            SizedBox(
              width: 160,
              child: TextField(
                enabled: !_isLoading,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 12),
                controller:
                    TextEditingController(text: _req.barDateTime),
                onSubmitted: (v) =>
                    setState(() => _req = _req.copyWith(barDateTime: v)),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _req.loadSize,
              isDense: true,
              dropdownColor: AppColors.surfaceVariant,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13),
              underline: const SizedBox(),
              items: _loadSizes
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text('$s')))
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (v) {
                      if (v != null) {
                        setState(() => _req = _req.copyWith(loadSize: v));
                      }
                    },
            ),
            const SizedBox(width: 12),
            if (_isLoading)
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else
              ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('GenerateSMA',
                    style: TextStyle(fontSize: 12)),
              ),
            const SizedBox(width: 12),
            Text('${_statusList.length} 件',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (_statusList.isEmpty) {
      return const Center(
          child: Text('データがありません',
              style: TextStyle(color: AppColors.textSecondary)));
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
            headingTextStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
          columns: const [
            DataColumn(label: Text('Symbol')),
            DataColumn(label: Text('BarDateTime')),
            DataColumn(label: Text('Count'), numeric: true),
            DataColumn(label: Text('ZigZagDateTime')),
            DataColumn(label: Text('ZigZag'), numeric: true),
            DataColumn(label: Text('BreakOut'), numeric: true),
            DataColumn(label: Text('BreakDown'), numeric: true),
            DataColumn(label: Text('Message')),
          ],
          rows: _statusList
              .map((s) => DataRow(cells: [
                    DataCell(Text(s.symbol,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 11))),
                    DataCell(Text(
                        '${_trimDt(s.barDateTimeMin)} ~ ${_trimDt(s.barDateTimeMax)}',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontFamily: 'monospace'))),
                    DataCell(Text(_fmt(s.barCount),
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 11))),
                    DataCell(Text(
                        '${_trimDt(s.barDateTimeMinZigZag)} ~ ${_trimDt(s.barDateTimeMaxZigZag)}',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontFamily: 'monospace'))),
                    DataCell(Text(_fmt(s.zigzagCount),
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 11))),
                    DataCell(Text(_fmt(s.breakResistanceCount),
                        style: const TextStyle(
                            color: AppColors.fxBuyLg, fontSize: 11))),
                    DataCell(Text(_fmt(s.breakSupportCount),
                        style: const TextStyle(
                            color: AppColors.fxSellLg, fontSize: 11))),
                    DataCell(Text(s.message ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 10))),
                  ]))
              .toList(),
          ),
        ),
      ),
    );
  }

  String _trimDt(String dt) {
    if (dt.isEmpty) return '';
    return dt.replaceAll('T', ' ').length > 16
        ? dt.replaceAll('T', ' ').substring(0, 16)
        : dt.replaceAll('T', ' ');
  }

  String _fmt(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');
}
