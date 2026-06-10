import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/simulator_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_drawer.dart';
import 'widgets/input_form_global.dart';
import 'widgets/simulator_panel.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimulatorProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FX Trade', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text('Simulator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: sim.isInitialized
          ? _buildBody(sim)
          : sim.errorMessage != null
              ? _buildError(sim)
              : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBody(SimulatorProvider sim) {
    return RefreshIndicator(
      onRefresh: sim.calculate,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const InputFormGlobal(),
            const SizedBox(height: 8),
            const SimulatorPanel(),
            if (sim.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Text(
                  sim.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(SimulatorProvider sim) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sim.errorMessage!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: sim.initialize,
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
