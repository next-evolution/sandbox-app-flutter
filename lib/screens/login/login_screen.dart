import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sandbox_user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

String _translateError(String msg) {
  if (msg.contains('Incorrect username or password')) return 'ユーザー名またはパスワードが正しくありません';
  if (msg.contains('User does not exist')) return 'ユーザーが見つかりません';
  if (msg.contains('Password attempts exceeded')) return 'ログイン試行回数が上限を超えました。しばらくしてから再試行してください';
  if (msg.contains('User is not confirmed')) return 'メールアドレスの確認が完了していません';
  if (msg.contains('Network') || msg.contains('SocketException')) return 'ネットワークエラーが発生しました';
  return msg;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.login(username, password);
      if (!mounted) return;

      switch (result) {
        case LoginSuccess():
          Navigator.of(context).pushReplacementNamed('/simulator');
        case LoginNewAccount():
          Navigator.of(context).pushReplacementNamed('/user/registration');
        case LoginPendingApproval():
          Navigator.of(context).pushReplacementNamed('/pending-approval');
        case LoginBlocked():
          Navigator.of(context).pushReplacementNamed('/error/blocked');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _translateError(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '✦ SANDBOX',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ようこそ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'アカウントにサインインしてください',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('ユーザー名', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'ユーザー名を入力',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          const Text('パスワード', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            keyboardType: TextInputType.visiblePassword,
            autofillHints: const [AutofillHints.password],
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'パスワードを入力',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Text(
                '⚠ $_error',
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('サインイン', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
