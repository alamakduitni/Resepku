import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/utils/string_formatter.dart';

bool _isNetwork(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

// Di web, file gambar dari server Laravel tidak membawa header CORS
// sehingga gagal dimuat lewat XHR. `fallback` menampilkannya memakai
// elemen <img> biasa jika itu terjadi.
const _webStrategy = WebHtmlElementStrategy.fallback;

/// Gambar resep dari server (URL) atau asset, dengan fade-in halus dan
/// fallback ikon.
class RecipeImage extends StatelessWidget {
  final String path;
  final double iconSize;

  const RecipeImage({super.key, required this.path, this.iconSize = 32});

  @override
  Widget build(BuildContext context) {
    Widget frameBuilder(
        BuildContext context, Widget child, int? frame, bool wasSyncLoaded) {
      if (wasSyncLoaded) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: child,
      );
    }

    Widget errorBuilder(BuildContext context, Object error, StackTrace? _) =>
        Container(
          color: AppColors.surfaceElevated,
          alignment: Alignment.center,
          child: Icon(AppIcons.restaurant,
              color: AppColors.disabledForeground, size: iconSize),
        );

    if (_isNetwork(path)) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        webHtmlElementStrategy: _webStrategy,
        frameBuilder: frameBuilder,
        errorBuilder: errorBuilder,
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
    );
  }
}

/// Foto pengunggah; jika tidak ada, diganti inisial nama.
class UploaderAvatar extends StatelessWidget {
  final String name;
  final String image;
  final double radius;

  const UploaderAvatar({
    super.key,
    required this.name,
    required this.image,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final initials = Container(
      color: AppColors.surfaceElevated,
      alignment: Alignment.center,
      child: Text(
        StringFormatter.initials(name),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
    Widget fallback(BuildContext context, Object error, StackTrace? _) =>
        initials;

    // Image (bukan CircleAvatar.backgroundImage) agar fallback <img> di web
    // tetap bisa dipakai; backgroundImage dilukis lewat canvas.
    final Widget photo;
    if (_isNetwork(image)) {
      photo = Image.network(
        image,
        fit: BoxFit.cover,
        webHtmlElementStrategy: _webStrategy,
        errorBuilder: fallback,
      );
    } else if (image.isNotEmpty) {
      photo = Image.asset(image, fit: BoxFit.cover, errorBuilder: fallback);
    } else {
      photo = initials;
    }

    return Semantics(
      image: true,
      label: 'Foto $name',
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
        ),
        child: ClipOval(
          child: SizedBox.square(dimension: radius * 2, child: photo),
        ),
      ),
    );
  }
}
