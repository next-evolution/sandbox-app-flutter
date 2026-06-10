import 'package:flutter/material.dart';
import '../../../../models/bar_data.dart';
import '../../../../models/economic_indicator_data.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';

class EIDataModal extends StatefulWidget {
  final int? dataId;
  final String? publication;
  final String defaultCountryCode;
  final List<KeyValue> countryList;
  final void Function(bool refresh) onClose;
  final void Function(String msg, bool isError) onToast;

  const EIDataModal({
    super.key,
    required this.dataId,
    required this.publication,
    required this.defaultCountryCode,
    required this.countryList,
    required this.onClose,
    required this.onToast,
  });

  @override
  State<EIDataModal> createState() => _EIDataModalState();
}

class _EIDataModalState extends State<EIDataModal> {
  final _api = ApiService();
  bool get _isNew => widget.dataId == null;

  List<KeyValue> _indicatorList = [];
  bool _isLoading = false;

  final _countryCodeNotifier = ValueNotifier<String>('');
  final _indicatorIdNotifier = ValueNotifier<int>(0);
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _subTitleCtrl = TextEditingController();
  final _resultCtrl = TextEditingController(text: '-');
  final _forecastCtrl = TextEditingController();
  final _previousCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  final _errors = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _countryCodeNotifier.dispose();
    _indicatorIdNotifier.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _subTitleCtrl.dispose();
    _resultCtrl.dispose();
    _forecastCtrl.dispose();
    _previousCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      if (_isNew) {
        final cc = widget.defaultCountryCode.isNotEmpty
            ? widget.defaultCountryCode
            : 'US';
        _countryCodeNotifier.value = cc;
        final list = await _loadIndicators(cc);
        if (!mounted) return;
        setState(() {
          _indicatorIdNotifier.value =
              list.isNotEmpty ? int.tryParse(list[0].key) ?? 0 : 0;
          _isLoading = false;
        });
      } else {
        final json = await _api.get(
            '/v1/fx/economic-indicator-data/${widget.dataId}/${Uri.encodeComponent(widget.publication!)}');
        final data = EconomicIndicatorData.fromJson(json);
        final list = await _loadIndicators(data.countryCode);
        if (!mounted) return;
        setState(() {
          _countryCodeNotifier.value = data.countryCode;
          _indicatorIdNotifier.value = data.id;
          _dateCtrl.text = data.publicationDate;
          _timeCtrl.text = data.publicationTime;
          _subTitleCtrl.text = data.subTitle ?? '';
          _resultCtrl.text = data.resultValue;
          _forecastCtrl.text = data.forecastValue ?? '';
          _previousCtrl.text = data.previousValue ?? '';
          _memoCtrl.text = data.memo ?? '';
          _indicatorList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      widget.onToast(e.toString(), true);
      widget.onClose(false);
    }
  }

  Future<List<KeyValue>> _loadIndicators(String countryCode) async {
    try {
      final list =
          await _api.getList('/v1/fx/master-list/economic-indicator/$countryCode');
      final kvList =
          list.map((e) => KeyValue.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) setState(() => _indicatorList = kvList);
      return kvList;
    } catch (_) {
      return [];
    }
  }

  Future<void> _onCountryChange(String cc) async {
    _countryCodeNotifier.value = cc;
    setState(() => _isLoading = true);
    final list = await _loadIndicators(cc);
    if (!mounted) return;
    setState(() {
      _indicatorIdNotifier.value =
          list.isNotEmpty ? int.tryParse(list[0].key) ?? 0 : 0;
      _isLoading = false;
    });
  }

  bool _validate() {
    final errs = <String>{};
    if (_countryCodeNotifier.value.isEmpty) errs.add('countryCode');
    if (_indicatorIdNotifier.value == 0) errs.add('indicatorId');
    if (_dateCtrl.text.isEmpty) errs.add('date');
    if (_timeCtrl.text.isEmpty) errs.add('time');
    if (_resultCtrl.text.isEmpty) errs.add('result');
    setState(() => _errors
      ..clear()
      ..addAll(errs));
    return errs.isEmpty;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    final publication = '${_dateCtrl.text} ${_timeCtrl.text}:00';
    final data = EconomicIndicatorData(
      id: _indicatorIdNotifier.value,
      countryCode: _countryCodeNotifier.value,
      name: '',
      importance: '',
      publication: publication,
      publicationDate: _dateCtrl.text,
      publicationTime: _timeCtrl.text,
      dayOfWeek: 0,
      subTitle: _subTitleCtrl.text.isNotEmpty ? _subTitleCtrl.text : null,
      resultValue: _resultCtrl.text,
      forecastValue:
          _forecastCtrl.text.isNotEmpty ? _forecastCtrl.text : null,
      previousValue:
          _previousCtrl.text.isNotEmpty ? _previousCtrl.text : null,
      memo: _memoCtrl.text.isNotEmpty ? _memoCtrl.text : null,
    );

    try {
      if (_isNew) {
        await _api.post('/v1/fx/economic-indicator-data', {'data': data.toJson()});
        widget.onToast('登録しました。', false);
      } else {
        await _api.put(
          '/v1/fx/economic-indicator-data/${widget.dataId}/${Uri.encodeComponent(widget.publication!)}',
          {'data': data.toJson()},
        );
        widget.onToast('更新しました。', false);
      }
      widget.onClose(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onToast(e.toString(), true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 440,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isNew ? '経済指標データ 登録フォーム' : '経済指標データ 編集フォーム',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                        onPressed: () => widget.onClose(false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _field(
                    '国コード',
                    ValueListenableBuilder<String>(
                      valueListenable: _countryCodeNotifier,
                      builder: (ctx, cc, child) => _dropdown<String>(
                        value: cc.isNotEmpty ? cc : null,
                        items: widget.countryList
                            .map((c) => DropdownMenuItem(
                                value: c.key,
                                child: Text('${c.key} - ${c.value}')))
                            .toList(),
                        hasError: _errors.contains('countryCode'),
                        onChanged: (v) {
                          if (v != null) _onCountryChange(v);
                        },
                      ),
                    ),
                  ),
                  _field(
                    '経済指標',
                    ValueListenableBuilder<int>(
                      valueListenable: _indicatorIdNotifier,
                      builder: (ctx, id, child) => _dropdown<int>(
                        value: _indicatorList.any(
                                (i) => int.tryParse(i.key) == id)
                            ? id
                            : null,
                        items: _indicatorList
                            .map((i) => DropdownMenuItem(
                                value: int.tryParse(i.key) ?? 0,
                                child: Text(i.value)))
                            .toList(),
                        hasError: _errors.contains('indicatorId'),
                        onChanged: (v) {
                          if (v != null) _indicatorIdNotifier.value = v;
                        },
                      ),
                    ),
                  ),
                  _field(
                    '発表日時',
                    Row(
                      children: [
                        Expanded(
                          child: _input(_dateCtrl,
                              hint: 'YYYY-MM-DD',
                              hasError: _errors.contains('date')),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 110,
                          child: _input(_timeCtrl,
                              hint: 'HH:MM',
                              hasError: _errors.contains('time')),
                        ),
                      ],
                    ),
                  ),
                  _field('サブタイトル', _input(_subTitleCtrl, hint: 'subtitle')),
                  _field(
                    '結果 / 予想 / 前回',
                    Row(
                      children: [
                        Expanded(
                          child: _input(_resultCtrl,
                              hint: '結果',
                              hasError: _errors.contains('result')),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _input(_forecastCtrl, hint: '予想')),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _input(_previousCtrl, hint: '前回')),
                      ],
                    ),
                  ),
                  _field(
                    'MEMO',
                    TextField(
                      controller: _memoCtrl,
                      maxLines: 3,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isNew
                            ? AppColors.primary
                            : AppColors.success,
                      ),
                      child: Text(_isNew ? '新規登録' : '更新'),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            child,
          ],
        ),
      );

  Widget _input(
    TextEditingController ctrl, {
    String? hint,
    bool hasError = false,
  }) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border),
          ),
        ),
        onChanged: (_) {
          if (_errors.isNotEmpty) setState(() => _errors.clear());
        },
      );

  Widget _dropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required bool hasError,
    required void Function(T?) onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: hasError ? AppColors.error : AppColors.border),
        ),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          dropdownColor: AppColors.surfaceVariant,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          underline: const SizedBox(),
          items: items,
          onChanged: onChanged,
        ),
      );
}
