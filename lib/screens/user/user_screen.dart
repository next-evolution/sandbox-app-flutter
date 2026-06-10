import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sandbox_user.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class UserScreen extends StatefulWidget {
  final bool isRegistration;

  const UserScreen({super.key, required this.isRegistration});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _nickNameController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String? _error;
  String? _email;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _email = auth.email;
    if (!widget.isRegistration && auth.user != null) {
      _nickNameController.text = auth.user!.nickName;
      _userId = auth.user!.userId;
    }
    if (!widget.isRegistration && auth.user == null) {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.get('/v1/user');
      final rawCode = res['returnCode'];
      final returnCode = rawCode is int ? rawCode : int.parse(rawCode.toString());
      if (returnCode == 0 && res['user'] != null) {
        final user = SandboxUser.fromJson(res['user'] as Map<String, dynamic>);
        if (mounted) {
          context.read<AuthProvider>().updateUser(user);
          setState(() {
            _nickNameController.text = user.nickName;
            _userId = user.userId;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final nickName = _nickNameController.text.trim();
    if (nickName.isEmpty) {
      setState(() => _error = 'NickName を入力してください');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic> res;
      if (widget.isRegistration) {
        res = await _api.post('/v1/user', {'nickName': nickName});
      } else {
        final userIdB64 = base64.encode(utf8.encode(_userId ?? ''));
        res = await _api.put('/v1/user/$userIdB64', {'nickName': nickName});
      }

      final rawCode = res['returnCode'];
      final returnCode = rawCode is int ? rawCode : int.parse(rawCode.toString());
      if (!mounted) return;

      if (returnCode != 0) {
        setState(() => _error = res['message'] as String? ?? 'エラーが発生しました');
        return;
      }
      if (res['user'] != null) {
        context.read<AuthProvider>().updateUser(
            SandboxUser.fromJson(res['user'] as Map<String, dynamic>));
      }
      Navigator.of(context).pushReplacementNamed('/simulator');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    super.dispose();
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
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isRegistration ? 'プロフィール登録' : 'プロフィール変更',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isRegistration
                          ? 'アカウント情報を登録してください'
                          : 'プロフィールを変更できます',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    const Text('Email', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _email ?? '',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('NickName', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nickNameController,
                      maxLength: 50,
                      enabled: !_isLoading,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: '例）Mr. Consideration',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        counterStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '⚠ $_error',
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              widget.isRegistration ? '登録' : '更新',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    if (!widget.isRegistration) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          '← メニューに戻る',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
