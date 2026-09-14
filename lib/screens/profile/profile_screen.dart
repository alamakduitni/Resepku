import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/string_formatter.dart';
import '../../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const _ProfileAvatar(),
              const SizedBox(height: 20),
              Text(
                _ProfileData.name,
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                _ProfileData.email,
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const _InfoCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNav(currentIndex: CustomBottomNav.indexProfile),
    );
  }
}

class _ProfileData {
  _ProfileData._();

  static const String name = 'Sari Wulandari';
  static const String email = 'sari.wulandari@email.com';
  static const String phone = '0812-3456-7890';
  static const String address = 'Surabaya, Jawa Timur';
  static const String birthDate = '14 Mei 1998';
  static const String photoAsset = 'assets/images/profiles/sari.jpg';
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  static const double _diameter = 128;
  static const double _ringWidth = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _diameter,
      height: _diameter,
      padding: const EdgeInsets.all(_ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: _ringWidth),
      ),
      child: ClipOval(
        child: Image.asset(
          _ProfileData.photoAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.surface,
            alignment: Alignment.center,
            child: Text(
              StringFormatter.initials(_ProfileData.name),
              style: AppTextStyles.heading1.copyWith(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          _InfoRow(
            icon: AppIcons.call,
            label: 'Nomor Telepon',
            value: _ProfileData.phone,
          ),
          Divider(color: AppColors.border, height: 1),
          _InfoRow(
            icon: AppIcons.locationOn,
            label: 'Alamat',
            value: _ProfileData.address,
          ),
          Divider(color: AppColors.border, height: 1),
          _InfoRow(
            icon: AppIcons.cake,
            label: 'Tanggal Lahir',
            value: _ProfileData.birthDate,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.valueBold),
            ],
          ),
        ],
      ),
    );
  }
}
