import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/string_formatter.dart';
import '../../data/api/api_client.dart';
import '../../data/stores/user_store.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/pressable.dart';
import '../../widgets/responsive.dart';
import '../auth/widgets/auth_validators.dart';

/// Form ubah data akun: nama, email, telepon, alamat, dan tanggal lahir.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = UserStore.instance;

  late final _name = TextEditingController(text: _store.user.value?.name);
  late final _email = TextEditingController(text: _store.user.value?.email);
  late final _phone = TextEditingController(text: _store.user.value?.phone);
  late final _address = TextEditingController(text: _store.user.value?.address);
  late DateTime? _birthDate = _store.user.value?.birthDate;

  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  static String? _phoneValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9\s-]{8,20}$').hasMatch(v)) {
      return 'Nomor telepon belum benar, contoh: 0812-3456-7890';
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      // Server hanya menerima tanggal sebelum hari ini.
      lastDate: DateTime(now.year, now.month, now.day - 1),
      helpText: 'Pilih tanggal lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await _store.updateProfile(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        address: _address.text,
        birthDate: _birthDate,
      );
      if (!mounted) return;
      AppSnackbar.show(context, 'Profil berhasil diperbarui',
          type: AppSnackbarType.success);
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Breakpoints.gutter(MediaQuery.sizeOf(context).width);
    var section = 0;
    Widget animated(Widget child) =>
        FadeSlideIn(delay: AppMotion.staggerFor(section++), child: child);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 68,
        leading: Center(
          child: IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(AppIcons.back),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
          children: [
            ResponsiveCenter(
              maxWidth: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  animated(AppTextField(
                    label: 'Nama Lengkap',
                    hintText: 'Nama lengkapmu',
                    prefixIcon: AppIcons.person,
                    controller: _name,
                    requiredField: true,
                    maxLength: 100,
                    validator: AuthValidators.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  )),
                  const SizedBox(height: 20),
                  animated(AppTextField(
                    label: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: AppIcons.mail,
                    controller: _email,
                    requiredField: true,
                    maxLength: 255,
                    validator: AuthValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                  )),
                  const SizedBox(height: 20),
                  animated(AppTextField(
                    label: 'Nomor Telepon',
                    hintText: 'Contoh: 0812-3456-7890',
                    prefixIcon: AppIcons.call,
                    controller: _phone,
                    maxLength: 20,
                    validator: _phoneValidator,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    ],
                  )),
                  const SizedBox(height: 20),
                  animated(AppTextField(
                    label: 'Alamat',
                    hintText: 'Contoh: Surabaya, Jawa Timur',
                    prefixIcon: AppIcons.locationOn,
                    controller: _address,
                    maxLength: 255,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.fullStreetAddress],
                  )),
                  const SizedBox(height: 20),
                  animated(_DateField(
                    value: _birthDate,
                    onTap: _pickBirthDate,
                    onClear: () => setState(() => _birthDate = null),
                  )),
                  const SizedBox(height: 32),
                  animated(AppButton(
                    label: 'Simpan Perubahan',
                    icon: AppIcons.check,
                    loading: _saving,
                    onPressed: _save,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Field tanggal lahir: ketuk untuk membuka kalender, tombol x untuk
/// mengosongkan.
class _DateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null ? null : StringFormatter.date(value!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Lahir', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Pressable(
          onTap: onTap,
          semanticLabel: text == null
              ? 'Tanggal lahir belum diisi, ketuk untuk memilih'
              : 'Tanggal lahir $text, ketuk untuk mengubah',
          hoverScale: 1.0,
          pressedScale: 0.98,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.cake, size: 22),
              suffixIcon: value == null
                  ? null
                  : IconButton(
                      tooltip: 'Kosongkan tanggal lahir',
                      onPressed: onClear,
                      icon: const Icon(AppIcons.close, size: 20),
                    ),
            ),
            child: Text(
              text ?? 'Pilih tanggal',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 15,
                color: text == null ? AppColors.textMuted : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
