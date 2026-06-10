import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sandbox',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (auth.user != null)
                      Text(
                        auth.user!.nickName,
                        style:
                            const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _section('FX Trade'),
                  _item(context, Icons.show_chart, 'Simulator', '/simulator', currentRoute),
                  _section('FX BarData'),
                  _item(context, Icons.bar_chart, 'BarData (Trade)', '/fx/bar-data/trade', currentRoute),
                  _item(context, Icons.bar_chart_outlined, 'BarData (Analyze)', '/fx/bar-data/analyze', currentRoute),
                  _section('FX Indicator'),
                  _item(context, Icons.calendar_today, 'Economic Indicator Data', '/fx/economic-indicator-data', currentRoute),
                  _item(context, Icons.timeline, 'ZigZag', '/fx/zigzag', currentRoute),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading:
                  const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
              title: const Text('プロフィール',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
              title: const Text('ログアウト',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              dense: true,
              onTap: () async {
                Navigator.pop(context);
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    String currentRoute,
  ) {
    final isActive = currentRoute == route;
    return ListTile(
      leading: Icon(icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      dense: true,
      tileColor: isActive ? AppColors.primary.withValues(alpha: 0.1) : null,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
