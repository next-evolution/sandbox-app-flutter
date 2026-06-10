import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/symbol_dto.dart';
import '../../../../models/trade_info.dart';
import '../../../../providers/simulator_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/input_price_field.dart';

class SimulatorPanel extends StatelessWidget {
  const SimulatorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final entry = sim.entry;
    final positions = sim.positionList;
    final symbolList = sim.symbolList;
    final symbolDto = symbolList.firstWhere(
      (s) => s.symbol == entry.symbol,
      orElse: () => SymbolDto.defaultSymbol,
    );
    final scale = symbolDto.validScale.toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, sim, entry, symbolList, scale),
          const Divider(height: 1, color: AppColors.border),
          _buildPriceRow(context, sim, entry, positions, scale),
          const Divider(height: 1, color: AppColors.border),
          _buildResultRow(context, positions),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SimulatorProvider sim, TradeEntry entry,
      List<SymbolDto> symbolList, int scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text('Symbol', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(width: 8),
          _buildSymbolDropdown(context, sim, entry, symbolList),
          const SizedBox(width: 8),
          _buildTradeTypeDropdown(context, sim, entry),
          const Spacer(),
          if (sim.isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: sim.calculate,
              child: const Text('Calculate', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildSymbolDropdown(BuildContext context, SimulatorProvider sim, TradeEntry entry,
      List<SymbolDto> symbolList) {
    return DropdownButton<String>(
      value: symbolList.any((s) => s.symbol == entry.symbol) ? entry.symbol : null,
      isDense: true,
      dropdownColor: AppColors.surfaceVariant,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      underline: const SizedBox(),
      items: symbolList
          .map((s) => DropdownMenuItem(value: s.symbol, child: Text(s.symbol)))
          .toList(),
      onChanged: sim.isLoading
          ? null
          : (v) {
              if (v != null) sim.updateEntry(entry.copyWith(symbol: v));
            },
    );
  }

  Widget _buildTradeTypeDropdown(BuildContext context, SimulatorProvider sim, TradeEntry entry) {
    return DropdownButton<String>(
      value: entry.tradeType,
      isDense: true,
      dropdownColor: AppColors.surfaceVariant,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 'L', child: Text('L')),
        DropdownMenuItem(value: 'S', child: Text('S')),
      ],
      onChanged: sim.isLoading
          ? null
          : (v) {
              if (v != null) sim.updateEntry(entry.copyWith(tradeType: v));
            },
    );
  }

  Widget _buildPriceRow(BuildContext context, SimulatorProvider sim, TradeEntry entry,
      List<TradePosition> positions, int scale) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ColHeader('Contract', AppColors.simBlue1),
                _ColHeader('Loss\n${entry.lossPips > 0 ? entry.lossPips : ""}', AppColors.simRed),
                _ColHeader('決済1\n${positions.isNotEmpty && positions[0].settlementPips > 0 ? positions[0].settlementPips : ""}', AppColors.simBlue1),
                _ColHeader('決済2\n${positions.length > 1 && positions[1].settlementPips > 0 ? positions[1].settlementPips : ""}', AppColors.simBlue2),
                _ColHeader('決済3\n${positions.length > 2 && positions[2].settlementPips > 0 ? positions[2].settlementPips : ""}', AppColors.simBlue3),
              ],
            ),
            Row(
              children: [
                _PriceInputCell(
                  price: entry.contractPrice,
                  scale: scale,
                  color: AppColors.simBlue1,
                  isZeroError: true,
                  onChanged: (v) => sim.updateEntry(entry.copyWith(contractPrice: v)),
                ),
                _PriceInputCell(
                  price: entry.lossPrice,
                  scale: scale,
                  color: AppColors.simRed,
                  isZeroError: true,
                  onChanged: (v) => sim.updateEntry(entry.copyWith(lossPrice: v)),
                ),
                for (int i = 0; i < 3; i++)
                  _PriceInputCell(
                    price: positions.length > i ? positions[i].settlementPrice : 0,
                    scale: scale,
                    color: i == 0 ? AppColors.simBlue1 : i == 1 ? AppColors.simBlue2 : AppColors.simBlue3,
                    isZeroError: i == 0,
                    onChanged: (v) {
                      if (positions.length > i) {
                        sim.updatePosition(i, positions[i].copyWith(settlementPrice: v));
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, List<TradePosition> positions) {
    const colors = [AppColors.simBlue1, AppColors.simBlue2, AppColors.simBlue3];

    Row buildRow(String label, List<Widget> cells) => Row(
          children: [
            SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ),
            ...cells,
          ],
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow('Lot', [
              for (int i = 0; i < 3; i++)
                _ResultValue(
                  positions.length > i
                      ? positions[i].lot.toStringAsFixed(2)
                      : '-',
                  colors[i],
                ),
            ]),
            const SizedBox(height: 2),
            buildRow('Profit', [
              for (int i = 0; i < 3; i++)
                _ProfitValue(
                  positions.length > i ? positions[i].profitAmount : 0,
                  colors[i],
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _ColHeader(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      color: color.withValues(alpha:0.25),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}

class _PriceInputCell extends StatelessWidget {
  final double price;
  final int scale;
  final Color color;
  final bool isZeroError;
  final ValueChanged<double> onChanged;

  const _PriceInputCell({
    required this.price,
    required this.scale,
    required this.color,
    required this.isZeroError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      color: color.withValues(alpha:0.1),
      child: InputPriceField(
        price: price,
        scale: scale,
        isZeroError: isZeroError,
        width: 90,
        onChanged: onChanged,
      ),
    );
  }
}

class _ResultLabel extends StatelessWidget {
  final String label;

  const _ResultLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    );
  }
}

class _ResultValue extends StatelessWidget {
  final String value;
  final Color color;

  const _ResultValue(this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      color: color.withValues(alpha:0.1),
      child: Text(
        value,
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
    );
  }
}

class _ProfitValue extends StatelessWidget {
  final int value;
  final Color color;

  const _ProfitValue(this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final textColor = value > 0 ? AppColors.fxBuy : value < 0 ? AppColors.fxSell : AppColors.textPrimary;
    final formatted = value.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      color: color.withValues(alpha:0.1),
      child: Text(
        value < 0 ? '-$formatted' : formatted,
        textAlign: TextAlign.right,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
