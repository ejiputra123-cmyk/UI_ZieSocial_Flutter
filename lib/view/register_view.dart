import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/view/login_view.dart';
import 'package:ziesocial/viewmodel/register_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedAvatar;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isNameFocused = false;
  bool _isUsernameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  // Design tokens konsisten dengan LoginView & HomeView
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryContainer = Color(0xFF6657E8);
  static const Color _primaryFixed = Color(0xFFE4DFFF);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _success = Color(0xFF006245);

  static const String _brandLogoUrl =
      'https://lh3.googleusercontent.com/aida/ALJJyrAfMs2ItwwCkd5S8GKnTKuYjyXKj8uj6XczHo5Kkahl1P0R2pCUqhdIyBuBiUKT0MAjFiZVsByNRJTFtlf7FuouANoUWjcAeNwiF9hxaWgN-0B81jMz39JlOwWlxmNMUSmZsj1llNc0BrxSoFljE0s7zrcnmc9D9QNWoNVIcmcTMssBiMeN3cg27oQvhb4wKfEzKaWwoH-z6RCVc3_5Win7EN8-OpOoPS5z6Ld-Iy7wmg';

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      setState(() => _isNameFocused = _nameFocusNode.hasFocus);
    });
    _usernameFocusNode.addListener(() {
      setState(() => _isUsernameFocused = _usernameFocusNode.hasFocus);
    });
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(
        () => _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _error : _success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final file = File(image.path);
    final fileSize = await file.length();

    if (fileSize > 5 * 1024 * 1024) {
      if (!mounted) return;
      _showSnackBar('Ukuran foto maksimal 5MB.');
      return;
    }

    final extension = image.path.split('.').last.toLowerCase();
    if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
      if (!mounted) return;
      _showSnackBar('Hanya format JPG, JPEG, atau PNG yang diperbolehkan.');
      return;
    }

    setState(() {
      _selectedAvatar = image;
    });
  }

  void _navigateToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Semua field wajib diisi.');
      return;
    }

    if (username.contains(' ')) {
      _showSnackBar('Username tidak boleh mengandung spasi.');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Format email tidak valid.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Password dan Confirm Password tidak sama.');
      return;
    }

    final viewModel = context.read<RegisterViewModel>();
    final success = await viewModel.register(
      name: name,
      username: username,
      email: email,
      password: password,
      avatarFilePath: _selectedAvatar?.path,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        viewModel.successMessage ?? 'Registrasi berhasil. Silakan login.',
        isError: false,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else {
      _showSnackBar(viewModel.errorMessage ?? 'Registrasi gagal.');
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required IconData prefixIcon,
    required String hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
    bool obscureText = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
        ),
        const Gap(4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isFocused ? _surfaceContainer : _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(prefixIcon, size: 20, color: _secondary),
              const Gap(12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  autofillHints: autofillHints,
                  obscureText: obscureText,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 21 / 14,
                    fontWeight: FontWeight.w400,
                    color: _onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      height: 21 / 14,
                      fontWeight: FontWeight.w400,
                      color: _secondary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (suffix != null) ...[const Gap(8), suffix],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RegisterViewModel>().isLoading;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: _navigateToLogin,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: _onSurface,
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),

                        // Branding Header
                        Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                _brandLogoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: _primaryContainer,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'z',
                                      style: TextStyle(
                                        color: _onPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Gap(8),
                            const Text(
                              'ziesocial',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                height: 30 / 24,
                                letterSpacing: -0.48,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                              ),
                            ),
                            const Gap(4),
                            const Text(
                              'Your moments, your community.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 18 / 13,
                                fontWeight: FontWeight.w500,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),

                        // Welcome Section
                        const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 24,
                            height: 30 / 24,
                            letterSpacing: -0.48,
                            fontWeight: FontWeight.w700,
                            color: _onSurface,
                          ),
                        ),
                        const Gap(4),
                        const Text(
                          'Join the community and start sharing your moments.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 21 / 14,
                            fontWeight: FontWeight.w400,
                            color: _secondary,
                          ),
                        ),
                        const Gap(20),

                        // Profile Photo Picker
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: isLoading ? null : _pickAvatar,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 84,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        color: _surfaceContainerLow,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedAvatar != null
                                              ? _primary
                                              : _primaryFixed,
                                          width: 2,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: _selectedAvatar != null
                                          ? Image.file(
                                              File(_selectedAvatar!.path),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 28,
                                              color: _secondary,
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: _primaryContainer,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _surface,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          _selectedAvatar != null
                                              ? Icons.edit
                                              : Icons.add,
                                          size: 14,
                                          color: _onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(8),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : (_selectedAvatar != null
                                          ? () => setState(
                                              () => _selectedAvatar = null,
                                            )
                                          : _pickAvatar),
                                child: Text(
                                  _selectedAvatar != null
                                      ? 'Remove photo'
                                      : 'Add profile photo (optional)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 16 / 12,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedAvatar != null
                                        ? _error
                                        : _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(20),

                        // Form Fields
                        _buildInputField(
                          label: 'Full name',
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          isFocused: _isNameFocused,
                          prefixIcon: Icons.person_outline,
                          hintText: 'Enter your full name',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                        ),
                        const Gap(14),

                        _buildInputField(
                          label: 'Username',
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          isFocused: _isUsernameFocused,
                          prefixIcon: Icons.alternate_email,
                          hintText: 'Choose a username',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                        ),
                        const Gap(14),

                        _buildInputField(
                          label: 'Email address',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          isFocused: _isEmailFocused,
                          prefixIcon: Icons.mail_outline,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const Gap(14),

                        _buildInputField(
                          label: 'Password',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          isFocused: _isPasswordFocused,
                          prefixIcon: Icons.lock_outline,
                          hintText: 'Create a password (min. 6 chars)',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          suffix: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: _secondary,
                              ),
                            ),
                          ),
                        ),
                        const Gap(14),

                        _buildInputField(
                          label: 'Confirm password',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          isFocused: _isConfirmPasswordFocused,
                          prefixIcon: Icons.lock_outline,
                          hintText: 'Re-enter your password',
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) {
                            if (!isLoading) _register();
                          },
                          suffix: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: _secondary,
                              ),
                            ),
                          ),
                        ),
                        const Gap(24),

                        // Submit Primary Button
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryContainer,
                              foregroundColor: _onPrimary,
                              disabledBackgroundColor: _primaryContainer
                                  .withValues(alpha: 0.7),
                              elevation: 1,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Create account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 22 / 16,
                                      letterSpacing: -0.16,
                                      fontWeight: FontWeight.w600,
                                      color: _onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        const Gap(24),

                        // Login Footer
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 21 / 14,
                                  fontWeight: FontWeight.w400,
                                  color: _secondary,
                                ),
                              ),
                              const Gap(4),
                              GestureDetector(
                                onTap: _navigateToLogin,
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 20 / 15,
                                    letterSpacing: -0.15,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

