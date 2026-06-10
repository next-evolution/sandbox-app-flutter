import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/simulator_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/input_price_field.dart';

class InputFormGlobal extends StatelessWidget {
  const InputFormGlobal({super.key});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final res = sim.response;

    final pos1 = res != null && res.positionList.isNotEmpty ? res.positionList[0].profitAmount : 0;
    final pos2 = res != null && res.positionList.length > 1 ? res.positionList[1].profitAmount : 0;
    final pos3 = res != null && res.positionList.length > 2 ? res.positionList[2].profitAmount : 0;
    final total = res?.entry.settlementAmount ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderCell('RiskAmount', AppColors.simRed),
                  _HeaderCell('Lot1', AppColors.simTeal),
                  _HeaderCell('USDJPY', AppColors.simAqua),
                  if (res != null) ...[
                    _HeaderCell('決済1', AppColors.simBlue1),
                    _HeaderCell('決済2', AppColors.simBlue2),
                    _HeaderCell('決済3', AppColors.simBlue3),
                    _HeaderCell('Total', AppColors.simBlue1, bold: true),
                  ],
                ],
              ),
              Row(
                children: [
                  _InputCell(
                    color: AppColors.simRed,
                    child: InputPriceField(
                      price: sim.riskAmount.toDouble(),
                      scale: 0,
                      width: 90,
                      onChanged: (v) => sim.setRiskAmount(v.toInt()),
                    ),
                  ),
                  _InputCell(
                    color: AppColors.simTeal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InputPriceField(
                          price: sim.firstLotRatio.toDouble(),
                          scale: 0,
                          width: 55,
                          onChanged: (v) => sim.setFirstLotRatio(v.toInt()),
                        ),
                        const SizedBox(width: 2),
                        const Text('%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  _InputCell(
                    color: AppColors.simAqua,
                    child: InputPriceField(
                      price: sim.priceJpy,
                      scale: 3,
                      width: 90,
                      onChanged: sim.setPriceJpy,
                    ),
                  ),
                  if (res != null) ...[
                    _ValueCell(pos1, AppColors.simBlue1),
                    _ValueCell(pos2, AppColors.simBlue2),
                    _ValueCell(pos3, AppColors.simBlue3),
                    _ValueCell(total, AppColors.simBlue1, bold: true),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final Color color;
  final bool bold;

  const _HeaderCell(this.label, this.color, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      color: color.withValues(alpha:0.25),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _InputCell extends StatelessWidget {
  final Widget child;
  final Color color;

  const _InputCell({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      color: color.withValues(alpha:0.1),
      child: child,
    );
  }
}

class _ValueCell extends StatelessWidget {
  final int value;
  final Color color;
  final bool bold;

  const _ValueCell(this.value, this.color, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final textColor = value > 0 ? AppColors.fxBuy : value < 0 ? AppColors.fxSell : AppColors.textPrimary;
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      color: color.withValues(alpha:0.1),
      child: Text(
        value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            ),
        textAlign: TextAlign.right,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
