import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _onDaftarPressed(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _onMasukPressed(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daftar Akun',
                  style: AppTextStyles.heading1.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Buat akun untuk mulai menjelajah resep.',
                  style: AppTextStyles.subtitle),
              const SizedBox(height: 32),
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 10),
              _buildTextField(
                hintText: 'Masukkan nama kamu',
                prefixIcon: AppIcons.person,
              ),
              const SizedBox(height: 22),
              _buildLabel('Email'),
              const SizedBox(height: 10),
              _buildTextField(
                hintText: 'Masukkan email kamu',
                prefixIcon: AppIcons.mail,
              ),
              const SizedBox(height: 22),
              _buildLabel('Kata Sandi'),
              const SizedBox(height: 10),
              _buildTextField(
                hintText: 'Masukkan kata sandi',
                prefixIcon: AppIcons.lock,
                dummyDots: true,
                suffixIcon: AppIcons.visibilityOff,
              ),
              const SizedBox(height: 32),
              _buildDaftarButton(context),
              const SizedBox(height: 20),
              _buildMasukLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.heading3);
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    bool dummyDots = false,
    IconData? suffixIcon,
  }) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(prefixIcon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dummyDots ? '••••••' : hintText,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 15,
                color: dummyDots ? AppColors.textPrimary : AppColors.textMuted,
                letterSpacing: dummyDots ? 2 : 0,
              ),
            ),
          ),
          if (suffixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(suffixIcon, color: AppColors.textMuted, size: 22),
            ),
        ],
      ),
    );
  }

  Widget _buildDaftarButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _onDaftarPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child:
            Text('Daftar', style: AppTextStyles.button.copyWith(fontSize: 16)),
      ),
    );
  }

  Widget _buildMasukLink(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium,
          children: [
            const TextSpan(text: 'Sudah punya akun? '),
            TextSpan(
              text: 'Masuk di sini',
              style: AppTextStyles.linkEmphasis,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _onMasukPressed(context),
            ),
          ],
        ),
      ),
    );
  }
}
