import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class InputPriceField extends StatefulWidget {
  final double price;
  final int scale;
  final bool isZeroError;
  final ValueChanged<double> onChanged;
  final double? width;

  const InputPriceField({
    super.key,
    required this.price,
    required this.scale,
    required this.onChanged,
    this.isZeroError = false,
    this.width,
  });

  @override
  State<InputPriceField> createState() => _InputPriceFieldState();
}

class _InputPriceFieldState extends State<InputPriceField> {
  late TextEditingController _controller;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.price));
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(InputPriceField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.price != widget.price) {
      _controller.text = _format(widget.price);
    }
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      final v = double.tryParse(_controller.text) ?? 0;
      _controller.text = _format(v);
      widget.onChanged(v);
    }
  }

  String _format(double v) {
    if (widget.scale == 0) return v.toInt().toString();
    return v.toStringAsFixed(widget.scale);
  }

  bool get _hasError =>
      widget.isZeroError && (double.tryParse(_controller.text) ?? 0) == 0;

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 100,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        style: TextStyle(
          color: _hasError ? AppColors.error : AppColors.textPrimary,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: _hasError ? AppColors.error : AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: _hasError ? AppColors.error : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
        ),
        onSubmitted: (v) {
          final parsed = double.tryParse(v) ?? 0;
          widget.onChanged(parsed);
        },
      ),
    );
  }
}
