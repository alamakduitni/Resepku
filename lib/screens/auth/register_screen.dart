import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/api/api_client.dart';
import '../../data/stores/user_store.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/cute_avatar.dart';
import 'widgets/auth_layout.dart';
import 'widgets/auth_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TapGestureRecognizer _masukRecognizer = TapGestureRecognizer()
    ..onTap = _onMasukPressed;

  bool _passwordFocused = false;
  bool _loading = false;
  double _strength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _masukRecognizer.dispose();
    super.dispose();
  }

  void _updateStrength(String value) {
    var score = 0.0;
    if (value.length >= 6) score += 0.34;
    if (value.length >= 10) score += 0.22;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.22;
    if (RegExp(r'[A-Z]').hasMatch(value) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      score += 0.22;
    }
    setState(() => _strength = score.clamp(0, 1));
  }

  (String, Color) get _strengthLabel {
    if (_strength < 0.34) return ('Lemah', AppColors.error);
    if (_strength < 0.7) return ('Cukup', AppColors.warning);
    return ('Kuat', AppColors.success);
  }

  Future<void> _onDaftarPressed() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackbar.show(context, 'Masih ada data yang perlu dilengkapi',
          type: AppSnackbarType.warning);
      return;
    }
    setState(() => _loading = true);
    final String message;
    try {
      message = await UserStore.instance.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
      return;
    }
    if (!mounted) return;
    AppSnackbar.show(context, message, type: AppSnackbarType.success);
    _backToLogin();
  }

  void _onMasukPressed() => _backToLogin();

  /// Kembali ke halaman Masuk tanpa menumpuk route Login baru.
  void _backToLogin() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (strengthText, strengthColor) = _strengthLabel;

    return AuthLayout(
      mascot: CuteAvatarData.presets[3],
      coverEyes: _passwordFocused,
      bubbleText: _passwordFocused
          ? 'Mata tertutup, rahasia aman!'
          : 'Yuk gabung, banyak resep enak menunggu!',
      title: 'Daftar Akun',
      subtitle: 'Buat akun untuk mulai menjelajah resep.',
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(AppIcons.back),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            minimumSize: const Size(48, 48),
          ),
        ),
      ),
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Nama Lengkap',
                hintText: 'Masukkan nama kamu',
                prefixIcon: AppIcons.person,
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: AuthValidators.name,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Email',
                hintText: 'nama@email.com',
                prefixIcon: AppIcons.mail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Kata Sandi',
                hintText: 'Minimal 6 karakter',
                prefixIcon: AppIcons.lock,
                controller: _passwordController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.password,
                onChanged: _updateStrength,
                onFocusChange: (f) => setState(() => _passwordFocused = f),
                onSubmitted: (_) => _onDaftarPressed(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: _strength),
                        duration: AppMotion.medium,
                        curve: AppMotion.enter,
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceElevated,
                          color: strengthColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: Text(
                      _passwordController.text.isEmpty
                          ? 'Kekuatan sandi'
                          : strengthText,
                      key: ValueKey(strengthText +
                          _passwordController.text.isEmpty.toString()),
                      style: AppTextStyles.caption.copyWith(
                        color: _passwordController.text.isEmpty
                            ? AppColors.textMuted
                            : strengthColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Daftar',
                loading: _loading,
                onPressed: _onDaftarPressed,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      const TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(
                        text: 'Masuk di sini',
                        style: AppTextStyles.linkEmphasis,
                        recognizer: _masukRecognizer,
                        mouseCursor: SystemMouseCursors.click,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
