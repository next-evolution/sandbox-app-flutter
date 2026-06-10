import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/simulator_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/user/user_screen.dart';
import 'screens/fx/simulator/simulator_screen.dart';
import 'screens/fx/bar_data/bar_data_screen.dart';
import 'screens/fx/economic_indicator_data/ei_data_screen.dart';
import 'screens/fx/zigzag/zigzag_screen.dart';
import 'screens/fx/zigzag/zigzag_generate_screen.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SimulatorProvider()),
      ],
      child: MaterialApp(
        title: 'Sandbox',
        theme: buildAppTheme(),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/user/registration': (_) => const UserScreen(isRegistration: true),
          '/user/profile': (_) => const UserScreen(isRegistration: false),
          '/simulator': (_) => const SimulatorScreen(),
          '/fx/bar-data/trade': (_) =>
              const BarDataScreen(symbolType: 'Trade'),
          '/fx/bar-data/analyze': (_) =>
              const BarDataScreen(symbolType: 'Analyze'),
          '/fx/economic-indicator-data': (_) => const EIDataScreen(),
          '/fx/zigzag': (_) => const ZigZagScreen(),
          '/fx/zigzag/generate': (_) => const ZigZagGenerateScreen(),
          '/pending-approval': (_) => const _MessageScreen(
                message: '承認待ちです。管理者の承認をお待ちください。',
              ),
          '/error/blocked': (_) => const _MessageScreen(
                message: 'このアカウントはブロックされています。管理者にお問い合わせください。',
              ),
        },
        builder: (context, child) => _AuthGate(child: child!),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  final Widget child;

  const _AuthGate({required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return child;
  }
}

class _MessageScreen extends StatelessWidget {
  final String message;

  const _MessageScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text('ログイン画面に戻る'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
