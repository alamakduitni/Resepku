import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_motion.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../data/models/recipe_model.dart';
import '../../data/api/api_client.dart';
import '../../data/stores/recipe_store.dart';
import '../../data/stores/user_store.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/cute_avatar.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/pressable.dart';
import '../../widgets/recipe_image.dart';
import '../../widgets/responsive.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _IngredientEntry {
  final int id;
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();

  _IngredientEntry(this.id);

  bool get isFilled =>
      name.text.trim().isNotEmpty && amount.text.trim().isNotEmpty;
  bool get isEmpty => name.text.trim().isEmpty && amount.text.trim().isEmpty;

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class _StepEntry {
  final int id;
  final TextEditingController text = TextEditingController();

  _StepEntry(this.id);

  bool get isFilled => text.text.trim().isNotEmpty;

  void dispose() => text.dispose();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  static const List<String> _coverOptions = [
    'assets/images/recipes/nasi_goreng_spesial.jpg',
    'assets/images/recipes/ayam_bakar_kecap.jpg',
    'assets/images/recipes/ayam_geprek.jpg',
    'assets/images/recipes/ikan_bakar_bumbu_kuning.jpg',
    'assets/images/recipes/pisang_goreng_crispy.jpg',
    'assets/images/recipes/keripik_tempe.jpg',
    'assets/images/recipes/es_teh_serai.jpg',
  ];

  static const double _minMinutes = 5;
  static const double _maxMinutes = 180;

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final List<_IngredientEntry> _ingredients = [];
  final List<_StepEntry> _steps = [];
  int _nextId = 0;

  String? _cover;

  /// Foto dari galeri; jika diisi, [_cover] dikosongkan (dan sebaliknya).
  PickedPhoto? _photo;
  bool _picking = false;
  String? _category;
  double _minutes = 30;
  bool _submitAttempted = false;
  bool _submitting = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onChanged);
    _addIngredient(animate: false);
    _addStep(animate: false);
    RecipeStore.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    for (final e in _ingredients) {
      e.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  // ---------------------------------------------------------------- state

  List<String> get _categories => RecipeStore.instance.categories
      .map((c) => c.name)
      .where((name) => name != 'Semua')
      .toList();

  bool get _hasCover => _cover != null || _photo != null;
  bool get _hasName => _nameController.text.trim().length >= 3;
  bool get _hasIngredients => _ingredients.any((e) => e.isFilled);
  bool get _hasSteps => _steps.any((s) => s.isFilled);

  double get _completion {
    final parts = [
      _hasCover,
      _hasName,
      _category != null,
      _hasIngredients,
      _hasSteps,
    ];
    return parts.where((p) => p).length / parts.length;
  }

  bool get _isDirty =>
      _hasCover ||
      _category != null ||
      _nameController.text.trim().isNotEmpty ||
      _ingredients.any((e) => !e.isEmpty) ||
      _steps.any((s) => s.isFilled);

  String get _mascotMessage {
    final c = _completion;
    if (c == 0) return 'Ayo mulai! Pilih foto sampul dulu ya.';
    if (c < 0.5) return 'Mantap, lanjutkan pelan-pelan.';
    if (c < 1) return 'Sedikit lagi resepmu siap dibagikan!';
    return 'Sempurna! Resepmu siap disimpan.';
  }

  void _addIngredient({bool animate = true}) {
    final entry = _IngredientEntry(_nextId++);
    entry.name.addListener(_onChanged);
    entry.amount.addListener(_onChanged);
    setState(() => _ingredients.add(entry));
    if (animate) HapticFeedback.selectionClick();
  }

  void _removeIngredient(_IngredientEntry entry) {
    HapticFeedback.lightImpact();
    setState(() => _ingredients.remove(entry));
    // Buang controller setelah frame agar field yang hilang tidak memakainya.
    WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
  }

  void _addStep({bool animate = true}) {
    final entry = _StepEntry(_nextId++);
    entry.text.addListener(_onChanged);
    setState(() => _steps.add(entry));
    if (animate) HapticFeedback.selectionClick();
  }

  void _removeStep(_StepEntry entry) {
    HapticFeedback.lightImpact();
    setState(() => _steps.remove(entry));
    WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
  }

  void _setMinutes(double value) {
    final v = value.clamp(_minMinutes, _maxMinutes);
    if (v == _minutes) return;
    HapticFeedback.selectionClick();
    setState(() => _minutes = v);
  }

  void _selectPreset(String path) {
    setState(() {
      _cover = path;
      _photo = null;
    });
  }

  Future<void> _pickPhoto() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      // Perkecil di perangkat agar unggahan cepat & di bawah batas 2 MB.
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) return; // dibatalkan

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > ApiConfig.maxPhotoBytes) {
        AppSnackbar.show(context, 'Ukuran foto maksimal 2 MB, pilih foto lain',
            type: AppSnackbarType.warning);
        return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        // PHP mengabaikan file multipart tanpa nama, jadi selalu beri nama.
        _photo = PickedPhoto(
          bytes: bytes,
          filename: file.name.isNotEmpty ? file.name : 'foto_resep.jpg',
        );
        _cover = null;
      });
    } on PlatformException {
      if (mounted) {
        AppSnackbar.show(context,
            'Tidak bisa membuka galeri. Periksa izin akses foto aplikasi.',
            type: AppSnackbarType.error);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  // ---------------------------------------------------------------- submit

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitAttempted = true);

    final formValid = _formKey.currentState?.validate() ?? false;
    final valid = formValid && _hasCover && _category != null;

    if (!valid) {
      HapticFeedback.heavyImpact();
      AppSnackbar.show(
        context,
        'Masih ada yang belum lengkap, cek bagian bertanda merah ya',
        type: AppSnackbarType.warning,
      );
      if (!_hasCover || _category == null) {
        _scrollController.animateTo(0,
            duration: AppMotion.slow, curve: AppMotion.emphasized);
      }
      return;
    }

    setState(() => _submitting = true);

    final RecipeModel recipe;
    try {
      recipe = await RecipeStore.instance.createRecipe(
        name: _nameController.text.trim(),
        category: _category!,
        cookingTimeMinutes: _minutes.round(),
        coverAsset: _photo == null ? _cover : null,
        photo: _photo,
        ingredients: [
          for (final e in _ingredients)
            if (e.isFilled)
              Ingredient(
                  name: e.name.text.trim(), amount: e.amount.text.trim()),
        ],
        steps: [
          for (final s in _steps)
            if (s.isFilled) s.text.text.trim(),
        ],
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _submitting = false);
      AppSnackbar.show(context, e.message, type: AppSnackbarType.error);
      return;
    }
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = false;
      _saved = true;
    });
    await _showSuccess(recipe);
  }

  Future<void> _showSuccess(RecipeModel recipe) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeSlideIn(
                beginScale: 0.6,
                beginOffset: Offset.zero,
                child: CuteAvatar(
                  data: UserStore.instance.avatar,
                  size: 110,
                  happy: true,
                ),
              ),
              const SizedBox(height: 18),
              const Text('Resep berhasil disimpan!',
                  style: AppTextStyles.heading2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                '"${recipe.name}" sekarang tampil paling atas di Beranda.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Lihat Resep',
                icon: AppIcons.restaurantMenu,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.detail,
                    arguments: recipe,
                  );
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Ke Beranda',
                variant: AppButtonVariant.ghost,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: CuteAvatar(data: CuteAvatarData.presets[3], size: 72),
        title: const Text('Buang draf resep?'),
        content: const Text('Isian yang sudah kamu tulis akan hilang.'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lanjut Menulis'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Buang'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => _saved = true); // izinkan pop
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final gutter = Breakpoints.gutter(MediaQuery.sizeOf(context).width);
    var section = 0;
    Widget animated(Widget child) =>
        FadeSlideIn(delay: AppMotion.staggerFor(section++), child: child);

    return PopScope(
      canPop: _saved || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leadingWidth: 68,
          leading: Center(
            child: IconButton(
              tooltip: 'Tutup',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(AppIcons.close),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
          title: const Text('Tambah Resep'),
          centerTitle: true,
        ),
        bottomNavigationBar: _BottomBar(
          completion: _completion,
          submitting: _submitting,
          onSubmit: _submit,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
            children: [
              ResponsiveCenter(
                maxWidth: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    animated(_ProgressCard(
                      completion: _completion,
                      message: _mascotMessage,
                    )),
                    const SizedBox(height: 24),
                    animated(_buildCoverSection()),
                    const SizedBox(height: 28),
                    animated(_buildBasicInfoSection()),
                    const SizedBox(height: 28),
                    animated(_buildTimeSection()),
                    const SizedBox(height: 28),
                    animated(_buildIngredientsSection()),
                    const SizedBox(height: 28),
                    animated(_buildStepsSection()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection() {
    final showError = _submitAttempted && !_hasCover;

    return _FormSection(
      icon: AppIcons.photoLibrary,
      title: 'Foto Sampul',
      requiredField: true,
      errorText: showError ? 'Pilih salah satu foto sampul' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: AppMotion.medium,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: showError ? AppColors.error : AppColors.border,
                width: showError ? 1.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AnimatedSwitcher(
                  duration: AppMotion.medium,
                  switchInCurve: AppMotion.enter,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween(begin: 1.06, end: 1.0).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _photo != null
                      ? SizedBox.expand(
                          key: ValueKey(_photo),
                          child: Image.memory(_photo!.bytes,
                              fit: BoxFit.cover, gaplessPlayback: true),
                        )
                      : _cover == null
                          ? Container(
                              key: const ValueKey('empty'),
                              color: AppColors.surface,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CuteAvatar(
                                      data: CuteAvatarData.presets[0],
                                      size: 64),
                                  const SizedBox(height: 10),
                                  const Text(
                                      'Unggah dari galeri atau pilih foto di bawah',
                                      style: AppTextStyles.bodyMedium,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          : SizedBox.expand(
                              key: ValueKey(_cover),
                              child: RecipeImage(path: _cover!, iconSize: 40),
                            ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              // Ubin pertama untuk unggah dari galeri.
              itemCount: _coverOptions.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _GalleryTile(
                    photo: _photo,
                    loading: _picking,
                    onTap: _pickPhoto,
                  );
                }
                final index = i - 1;
                final path = _coverOptions[index];
                final selected = path == _cover;
                return Pressable(
                  onTap: () => _selectPreset(path),
                  selected: selected,
                  semanticLabel: 'Foto sampul ${index + 1}',
                  hoverScale: 1.06,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: AppMotion.medium,
                    curve: AppMotion.emphasized,
                    width: 76,
                    padding: EdgeInsets.all(selected ? 3 : 0),
                    decoration: BoxDecoration(
                      gradient: selected ? AppColors.primaryGradient : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(selected ? 13 : 16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          RecipeImage(path: path, iconSize: 20),
                          AnimatedOpacity(
                            opacity: selected ? 1 : 0,
                            duration: AppMotion.fast,
                            child: Container(
                              color: Colors.black38,
                              alignment: Alignment.center,
                              child: const Icon(AppIcons.check,
                                  color: Colors.white, size: 26, weight: 700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final categories = _categories;
    final showCategoryError = _submitAttempted && _category == null;

    return _FormSection(
      icon: AppIcons.restaurantMenu,
      title: 'Informasi Dasar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Nama Resep',
            requiredField: true,
            hintText: 'Contoh: Soto Ayam Lamongan',
            controller: _nameController,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Nama resep wajib diisi';
              if (value.length < 3) return 'Nama resep minimal 3 huruf';
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text.rich(
            TextSpan(
              text: 'Kategori',
              children: [
                TextSpan(
                    text: ' *', style: TextStyle(color: AppColors.primary)),
              ],
            ),
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 10),
          if (categories.isEmpty)
            const LinearProgressIndicator(color: AppColors.primary)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in categories)
                  _ChoicePill(
                    label: name,
                    selected: _category == name,
                    onTap: () => setState(() => _category = name),
                  ),
              ],
            ),
          _ErrorText(
              text: showCategoryError ? 'Pilih satu kategori resep' : null),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return _FormSection(
      icon: AppIcons.timer,
      title: 'Waktu Memasak',
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _RoundStepButton(
                  icon: AppIcons.remove,
                  tooltip: 'Kurangi 5 menit',
                  onTap: _minutes > _minMinutes
                      ? () => _setMinutes(_minutes - 5)
                      : null,
                ),
                Expanded(
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.fast,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero)
                                .animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          '${_minutes.round()}',
                          key: ValueKey(_minutes.round()),
                          style: AppTextStyles.display
                              .copyWith(color: AppColors.primary, fontSize: 36),
                        ),
                      ),
                      const Text('menit', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                _RoundStepButton(
                  icon: AppIcons.add,
                  tooltip: 'Tambah 5 menit',
                  onTap: _minutes < _maxMinutes
                      ? () => _setMinutes(_minutes + 5)
                      : null,
                ),
              ],
            ),
            Slider(
              value: _minutes,
              min: _minMinutes,
              max: _maxMinutes,
              divisions: ((_maxMinutes - _minMinutes) / 5).round(),
              label: '${_minutes.round()} menit',
              semanticFormatterCallback: (v) => '${v.round()} menit',
              onChanged: _setMinutes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    final showError = _submitAttempted && !_hasIngredients;

    return _FormSection(
      icon: AppIcons.basket,
      title: 'Bahan-Bahan',
      requiredField: true,
      trailing: '${_ingredients.where((e) => e.isFilled).length} bahan',
      errorText: showError ? 'Tambahkan minimal satu bahan' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (var i = 0; i < _ingredients.length; i++)
                  FadeSlideIn(
                    key: ValueKey(_ingredients[i].id),
                    beginOffset: const Offset(0, -0.15),
                    duration: AppMotion.medium,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IngredientRow(
                        index: i,
                        entry: _ingredients[i],
                        canRemove: _ingredients.length > 1,
                        onRemove: () => _removeIngredient(_ingredients[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _AddRowButton(label: 'Tambah Bahan', onTap: _addIngredient),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    final showError = _submitAttempted && !_hasSteps;

    return _FormSection(
      icon: AppIcons.listNumbered,
      title: 'Langkah-Langkah',
      requiredField: true,
      trailing: '${_steps.where((s) => s.isFilled).length} langkah',
      errorText: showError ? 'Tuliskan minimal satu langkah' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                for (var i = 0; i < _steps.length; i++)
                  FadeSlideIn(
                    key: ValueKey(_steps[i].id),
                    beginOffset: const Offset(0, -0.15),
                    duration: AppMotion.medium,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StepRow(
                        index: i,
                        entry: _steps[i],
                        canRemove: _steps.length > 1,
                        onRemove: () => _removeStep(_steps[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _AddRowButton(label: 'Tambah Langkah', onTap: _addStep),
        ],
      ),
    );
  }
}

// ======================================================================
// Komponen pendukung
// ======================================================================

class _ProgressCard extends StatelessWidget {
  final double completion;
  final String message;

  const _ProgressCard({required this.completion, required this.message});

  @override
  Widget build(BuildContext context) {
    final done = completion >= 1;

    return AnimatedContainer(
      duration: AppMotion.slow,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            (done ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.2),
            AppColors.surface,
          ],
        ),
        border: Border.all(
          color: (done ? AppColors.success : AppColors.primary)
              .withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: UserStore.instance.avatarIndex,
            builder: (context, _, __) => CuteAvatar(
              data: UserStore.instance.avatar,
              size: 64,
              happy: done,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Kelengkapan', style: AppTextStyles.caption),
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: completion),
                      duration: AppMotion.slow,
                      builder: (context, v, _) => Text(
                        '${(v * 100).round()}%',
                        style: AppTextStyles.valueBold.copyWith(
                          color: done ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: completion),
                    duration: AppMotion.slow,
                    curve: AppMotion.emphasized,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceElevated,
                      color: done ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: AppMotion.medium,
                  child: Text(
                    message,
                    key: ValueKey(message),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool requiredField;
  final String? trailing;
  final String? errorText;

  const _FormSection({
    required this.icon,
    required this.title,
    required this.child,
    this.requiredField = false,
    this.trailing,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: title,
                  children: [
                    if (requiredField)
                      const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.primary)),
                  ],
                ),
                style: AppTextStyles.heading2,
              ),
            ),
            if (trailing != null)
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Text(trailing!,
                    key: ValueKey(trailing), style: AppTextStyles.caption),
              ),
          ],
        ),
        const SizedBox(height: 14),
        child,
        _ErrorText(text: errorText),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String? text;

  const _ErrorText({required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppMotion.fast,
      alignment: Alignment.topLeft,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(AppIcons.error,
                        size: 16, color: AppColors.error, fill: 1),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(text!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      hoverScale: 1.05,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? Colors.transparent : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: AppMotion.fast,
              child: selected
                  ? const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(AppIcons.check,
                          size: 16, color: Colors.white, weight: 700),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _RoundStepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        semanticLabel: tooltip,
        pressedScale: 0.85,
        hoverScale: 1.08,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedOpacity(
          duration: AppMotion.fast,
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final int index;
  final _IngredientEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;

  const _IngredientRow({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 380;

    final nameField = AppTextField(
      label: '',
      hintText: 'Nama bahan',
      controller: entry.name,
      dense: true,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (entry.isEmpty && index > 0) return 'Isi atau hapus baris ini';
        if ((v?.trim() ?? '').isEmpty) return 'Nama bahan wajib';
        return null;
      },
    );
    final amountField = AppTextField(
      label: '',
      hintText: 'Takaran',
      controller: entry.amount,
      dense: true,
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (entry.isEmpty && index > 0) return null;
        if ((v?.trim() ?? '').isEmpty) return 'Takaran wajib';
        return null;
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IndexBadge(number: index + 1),
        const SizedBox(width: 10),
        Expanded(
          child: narrow
              ? Column(
                  children: [nameField, const SizedBox(height: 8), amountField],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: nameField),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: amountField),
                  ],
                ),
        ),
        _RemoveButton(
          enabled: canRemove,
          tooltip: 'Hapus bahan ${index + 1}',
          onTap: onRemove,
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final _StepEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;

  const _StepRow({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IndexBadge(number: index + 1),
        const SizedBox(width: 10),
        Expanded(
          child: AppTextField(
            label: '',
            hintText: 'Jelaskan langkah ${index + 1}...',
            controller: entry.text,
            dense: true,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) {
                return index > 0
                    ? 'Isi atau hapus langkah ini'
                    : 'Langkah pertama wajib diisi';
              }
              if (value.length < 5) return 'Tulis langkah lebih jelas';
              return null;
            },
          ),
        ),
        _RemoveButton(
          enabled: canRemove,
          tooltip: 'Hapus langkah ${index + 1}',
          onTap: onRemove,
        ),
      ],
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int number;

  const _IndexBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final bool enabled;
  final String tooltip;
  final VoidCallback onTap;

  const _RemoveButton({
    required this.enabled,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 2),
      child: IconButton(
        tooltip: tooltip,
        onPressed: enabled ? onTap : null,
        icon: const Icon(AppIcons.delete, size: 22),
        color: AppColors.textMuted,
        hoverColor: AppColors.error.withValues(alpha: 0.12),
        highlightColor: AppColors.error.withValues(alpha: 0.2),
        disabledColor: AppColors.border,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

class _AddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddRowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      hoverScale: 1.01,
      pressedScale: 0.97,
      hoverGlowColor: AppColors.primary,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.add, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style:
                      AppTextStyles.button.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ubin "Galeri" di pemilih sampul. Setelah foto dipilih, ubin ini
/// menampilkan fotonya dan bisa diketuk lagi untuk mengganti.
class _GalleryTile extends StatelessWidget {
  final PickedPhoto? photo;
  final bool loading;
  final VoidCallback onTap;

  const _GalleryTile({
    required this.photo,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = photo != null;

    return Tooltip(
      message: selected ? 'Ganti foto dari galeri' : 'Unggah dari galeri',
      // Label untuk pembaca layar sudah diberikan oleh Pressable.
      excludeFromSemantics: true,
      child: Pressable(
        onTap: loading ? null : onTap,
        selected: selected,
        semanticLabel:
            selected ? 'Ganti foto dari galeri' : 'Pilih dari galeri',
        hoverScale: 1.06,
        hoverGlowColor: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        // Teks "Galeri" sudah tercakup dalam semanticLabel di atas.
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            width: 76,
            padding: EdgeInsets.all(selected ? 3 : 0),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: selected
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(photo!.bytes,
                            fit: BoxFit.cover, gaplessPlayback: true),
                        Container(
                          color: Colors.black38,
                          alignment: Alignment.center,
                          child: const Icon(AppIcons.check,
                              color: Colors.white, size: 26, weight: 700),
                        ),
                      ],
                    ),
                  )
                : CustomPaint(
                    painter: _DashedBorderPainter(),
                    child: Center(
                      child: loading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: AppColors.primary),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(AppIcons.addPhoto,
                                    color: AppColors.primary, size: 24),
                                const SizedBox(height: 4),
                                Text('Galeri',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.primary)),
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

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    canvas.drawRRect(
      rrect,
      Paint()..color = AppColors.primary.withValues(alpha: 0.06),
    );
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomBar extends StatelessWidget {
  final double completion;
  final bool submitting;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.completion,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AppButton(
                label: 'Simpan Resep',
                icon: AppIcons.check,
                loading: submitting,
                onPressed: onSubmit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
