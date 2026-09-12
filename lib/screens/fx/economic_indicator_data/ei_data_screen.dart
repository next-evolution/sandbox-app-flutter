import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/bar_data.dart';
import '../../../models/economic_indicator_data.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/search_pager.dart';
import 'widgets/ei_data_modal.dart';

const _pageSizes = [50, 100, 200, 500];
const _days = ['日', '月', '火', '水', '木', '金', '土'];

class EIDataScreen extends StatefulWidget {
  const EIDataScreen({super.key});

  @override
  State<EIDataScreen> createState() => _EIDataScreenState();
}

class _EIDataScreenState extends State<EIDataScreen> {
  final _api = ApiService();
  EIDSearchResponse _res =
      EIDSearchResponse(totalCount: 0, totalPage: 0, list: []);
  EIDSearchRequest _req = EIDSearchRequest(page: 1, size: 100, sortAsc: false);
  List<KeyValue> _countryList = [];
  List<KeyValue> _indicatorList = [];
  bool _isLoading = false;
  String? _errorMsg;
  String? _toastMsg;
  bool _toastError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final countryRaw = await _api.getList('/v1/fx/master-list/country');
      final countries =
          countryRaw.map((e) => KeyValue.fromJson(e as Map<String, dynamic>)).toList();
      final indicatorRaw =
          await _api.getList('/v1/fx/master-list/economic-indicator/ALL');
      final indicators =
          indicatorRaw.map((e) => KeyValue.fromJson(e as Map<String, dynamic>)).toList();
      final json = await _api.post(
          '/v1/fx/economic-indicator-data/search', _req.toJson());
      final res = EIDSearchResponse.fromJson(json);
      if (!mounted) return;
      setState(() {
        _countryList = countries;
        _indicatorList = indicators;
        _res = res;
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

  Future<void> _search(EIDSearchRequest req) async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final json =
          await _api.post('/v1/fx/economic-indicator-data/search', req.toJson());
      final res = EIDSearchResponse.fromJson(json);
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

  Future<void> _loadIndicators(String countryCode) async {
    try {
      final raw =
          await _api.getList('/v1/fx/master-list/economic-indicator/$countryCode');
      final list =
          raw.map((e) => KeyValue.fromJson(e as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() => _indicatorList = list);
    } catch (_) {}
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

  void _openModal({int? id, String? publication}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EIDataModal(
        dataId: id,
        publication: publication,
        defaultCountryCode: _req.countryCode ?? 'US',
        countryList: _countryList,
        onClose: (refresh) {
          Navigator.pop(context);
          if (refresh) _search(_req);
        },
        onToast: _showToast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.user?.admin == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FX Indicator',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('Economic Indicator Data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              tooltip: 'ADD',
              onPressed: _openModal,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(isAdmin),
              if (_errorMsg != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(_errorMsg!,
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTable(isAdmin),
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
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isAdmin) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _req.sortAsc,
                      onChanged: (v) =>
                          _search(_req.copyWith(sortAsc: v ?? false, page: 1)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text('ASC',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 12),
                const Text('重要度:',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 4),
                DropdownButton<String>(
                  value: _req.importance ?? '',
                  isDense: true,
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('全件')),
                    DropdownMenuItem(value: 'H', child: Text('H - 高')),
                    DropdownMenuItem(value: 'M', child: Text('M - 中')),
                    DropdownMenuItem(value: 'X', child: Text('X - 低')),
                    DropdownMenuItem(value: 'Z', child: Text('Z - その他')),
                  ],
                  onChanged: (v) {
                    final imp = v ?? '';
                    _search(_req.copyWith(
                      importance: imp.isEmpty ? null : imp,
                      clearImportance: imp.isEmpty,
                      page: 1,
                    ));
                  },
                ),
                const SizedBox(width: 12),
                const Text('国:',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 4),
                DropdownButton<String>(
                  value: _req.countryCode ?? '',
                  isDense: true,
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('-')),
                    ..._countryList.map((c) => DropdownMenuItem(
                        value: c.key, child: Text('${c.key} - ${c.value}'))),
                  ],
                  onChanged: (v) {
                    final cc = v!.isEmpty ? null : v;
                    if (cc != null) _loadIndicators(cc);
                    _search(_req.copyWith(
                      countryCode: cc,
                      clearCountryCode: cc == null,
                      clearId: true,
                      page: 1,
                    ));
                  },
                ),
                const SizedBox(width: 12),
                const Text('指標:',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 4),
                DropdownButton<int>(
                  value: _req.id ?? 0,
                  isDense: true,
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('-')),
                    ..._indicatorList.map((i) => DropdownMenuItem(
                        value: int.tryParse(i.key) ?? 0,
                        child: Text(i.value))),
                  ],
                  onChanged: (v) => _search(_req.copyWith(
                    id: v == 0 ? null : v,
                    clearId: v == 0,
                    page: 1,
                  )),
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

  Widget _buildTable(bool isAdmin) {
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
            columnSpacing: 10,
          headingTextStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          columns: const [
            DataColumn(label: Text('★')),
            DataColumn(label: Text('Publication')),
            DataColumn(label: Text('Country')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('発表値'), numeric: true),
            DataColumn(label: Text('')),
            DataColumn(label: Text('予想値'), numeric: true),
            DataColumn(label: Text('')),
            DataColumn(label: Text('前回値'), numeric: true),
            DataColumn(label: Text('')),
          ],
          rows: _res.list.map((row) {
            final isHigh = row.importance == 'H';
            final pub = _formatPub(row);
            final name = row.subTitle != null
                ? '${row.subTitle}${row.name}'
                : row.name;
            return DataRow(
              color: WidgetStateProperty.all(
                  isHigh ? AppColors.importanceHighBg : Colors.transparent),
              onLongPress: isAdmin
                  ? () => _openModal(id: row.id, publication: row.publication)
                  : null,
              cells: [
                DataCell(Text(_importanceLabel(row.importance),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 11))),
                DataCell(Text(pub,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 11))),
                DataCell(Text(
                    '${row.countryCode}-${row.countryNameShort ?? ''}',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 11))),
                DataCell(Text(name,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 12))),
                DataCell(_resultCell(row)),
                DataCell(Text(row.unitOfValue ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10))),
                DataCell(Text(row.forecastValue ?? '',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 11))),
                DataCell(Text(row.unitOfValue ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10))),
                DataCell(Text(row.previousValue ?? '',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 11))),
                DataCell(Text(row.unitOfValue ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10))),
              ],
            );
          }).toList(),
          ),
        ),
      ),
    );
  }

  String _importanceLabel(String v) => v == 'H'
      ? '高'
      : v == 'M'
          ? '中'
          : v == 'X'
              ? '情'
              : v == 'Z'
                  ? '重'
                  : v;

  String _formatPub(EconomicIndicatorData row) {
    try {
      final d = DateTime.parse(row.publicationDate);
      final day = _days[d.weekday % 7];
      final mm = row.publicationDate.substring(5, 7);
      final dd = row.publicationDate.substring(8, 10);
      final hh = row.publicationTime.substring(0, 2);
      final min = row.publicationTime.substring(3, 5);
      return '${row.publicationDate.substring(0, 4)}/$mm/$dd ($day) $hh:$min';
    } catch (_) {
      return row.publication;
    }
  }

  Widget _resultCell(EconomicIndicatorData row) {
    Color color = AppColors.textPrimary;
    bool bold = false;
    final rv = row.resultValue;
    if (rv != '-') {
      String? prev = row.forecastValue ?? row.previousValue;
      if (prev != null) {
        if (prev.contains('(')) prev = prev.split('(')[0];
        final rf = double.tryParse(rv);
        final pf = double.tryParse(prev);
        if (rf != null && pf != null) {
          if (rf > pf) {
            color = AppColors.fxBuyLg;
            bold = true;
          } else if (rf == pf) {
            color = AppColors.textSecondary;
          } else {
            color = AppColors.fxSellLg;
            bold = true;
          }
        }
      }
    }
    return Text(rv,
        style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal));
  }
}
