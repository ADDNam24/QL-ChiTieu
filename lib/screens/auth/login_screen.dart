import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool hasPassword) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = hasPassword
        ? auth.login(_passwordController.text)
        : await auth.setupPassword(_passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasPassword
                ? 'Mật khẩu không đúng'
                : 'Không thể tạo mật khẩu, vui lòng thử lại',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPassword = context.watch<AuthProvider>().hasPassword;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.largePadding),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.inputFill,
                        child: Icon(
                          hasPassword
                              ? Icons.lock_open_outlined
                              : Icons.password_outlined,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        hasPassword ? 'Mở khóa ứng dụng' : 'Tạo mật khẩu',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasPassword
                            ? 'Nhập đúng mật khẩu đã tạo để vào ứng dụng.'
                            : 'Thiết lập mật khẩu cho lần sử dụng đầu tiên.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (!hasPassword && value.trim().length < 4) {
                            return 'Mật khẩu cần ít nhất 4 ký tự';
                          }
                          return null;
                        },
                      ),
                      if (!hasPassword) ...[
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Nhập lại mật khẩu',
                          icon: Icons.verified_user_outlined,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập lại mật khẩu';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu nhập lại không trùng';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 22),
                      CustomButton(
                        label: hasPassword ? 'Vào ứng dụng' : 'Tạo và vào app',
                        icon: hasPassword ? Icons.login : Icons.check,
                        isLoading: _isLoading,
                        onPressed: () => _submit(hasPassword),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
