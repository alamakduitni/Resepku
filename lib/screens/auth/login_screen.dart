import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TapGestureRecognizer _daftarRecognizer = TapGestureRecognizer()
    ..onTap = _onDaftarPressed;

  bool _passwordFocused = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _daftarRecognizer.dispose();
    super.dispose();
  }

  Future<void> _onMasukPressed() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackbar.show(context, 'Periksa kembali email dan kata sandimu',
          type: AppSnackbarType.warning);
      return;
    }
    setState(() => _loading = true);
    try {
      await UserStore.instance.login(
          _emailController.text.trim(), _passwordController.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _onDaftarPressed() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      mascot: CuteAvatarData.presets[0],
      coverEyes: _passwordFocused,
      bubbleText: _passwordFocused
          ? 'Tenang, aku nggak ngintip kok!'
          : 'Halo lagi! Siap masak hari ini?',
      title: 'Masuk',
      subtitle: 'Selamat datang kembali 👋',
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                autofillHints: const [AutofillHints.password],
                validator: AuthValidators.password,
                onFocusChange: (f) => setState(() => _passwordFocused = f),
                onSubmitted: (_) => _onMasukPressed(),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Masuk',
                loading: _loading,
                onPressed: _onMasukPressed,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      const TextSpan(text: 'Belum punya akun? '),
                      TextSpan(
                        text: 'Daftar di sini',
                        style: AppTextStyles.linkEmphasis,
                        recognizer: _daftarRecognizer,
                        mouseCursor: SystemMouseCursors.click,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Data akun masih dummy — isi email & sandi apa saja.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
