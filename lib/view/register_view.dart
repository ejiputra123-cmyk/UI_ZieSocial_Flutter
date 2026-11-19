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

  // Design System ZieSocial
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryContainer = Color(0xFF6657E8);
  static const Color _primaryFixed = Color(0xFFE4DFFF);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _success = Color(0xFF006245);

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_onNameFocusChanged);
    _usernameFocusNode.addListener(_onUsernameFocusChanged);
    _emailFocusNode.addListener(_onEmailFocusChanged);
    _passwordFocusNode.addListener(_onPasswordFocusChanged);
    _confirmPasswordFocusNode.addListener(_onConfirmPasswordFocusChanged);
  }

  void _onNameFocusChanged() {
    if (mounted) setState(() => _isNameFocused = _nameFocusNode.hasFocus);
  }

  void _onUsernameFocusChanged() {
    if (mounted) {
      setState(() => _isUsernameFocused = _usernameFocusNode.hasFocus);
    }
  }

  void _onEmailFocusChanged() {
    if (mounted) setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
  }

  void _onPasswordFocusChanged() {
    if (mounted) {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    }
  }

  void _onConfirmPasswordFocusChanged() {
    if (mounted) {
      setState(
        () => _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus,
      );
    }
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onNameFocusChanged);
    _usernameFocusNode.removeListener(_onUsernameFocusChanged);
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _passwordFocusNode.removeListener(_onPasswordFocusChanged);
    _confirmPasswordFocusNode.removeListener(_onConfirmPasswordFocusChanged);

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

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RegisterViewModel>().isLoading;

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Top Navigation & Header (Rata Tengah)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Transform.translate(
                                offset: const Offset(-10, 0),
                                child: Semantics(
                                  button: true,
                                  label: 'Back to Sign in',
                                  child: InkWell(
                                    onTap: isLoading ? null : _navigateToLogin,
                                    borderRadius: BorderRadius.circular(22),
                                    child: const SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Icon(
                                        Icons.arrow_back_rounded,
                                        size: 24,
                                        color: _onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(12),

                            const Text(
                              'Create account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                height: 1.2,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                              ),
                            ),
                            const Gap(6),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                    color: _secondary,
                                  ),
                                ),
                                InkWell(
                                  onTap: isLoading ? null : _navigateToLogin,
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: _primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Gap(20),

                            // 2. Compact Avatar Picker (Rata Tengah)
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Semantics(
                                    button: true,
                                    label: _selectedAvatar != null
                                        ? 'Change profile photo'
                                        : 'Add profile photo',
                                    child: InkWell(
                                      onTap: isLoading ? null : _pickAvatar,
                                      customBorder: const CircleBorder(),
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: _surfaceContainerLow,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _selectedAvatar != null
                                                ? _primary
                                                : _primaryFixed,
                                            width: 1.5,
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
                                                size: 22,
                                                color: _secondary,
                                              ),
                                      ),
                                    ),
                                  ),
                                  const Gap(14),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 12,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: isLoading
                                                  ? null
                                                  : _pickAvatar,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                child: Text(
                                                  _selectedAvatar != null
                                                      ? 'Change photo'
                                                      : 'Add profile photo',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    height: 1.35,
                                                    fontWeight: FontWeight.w600,
                                                    color: _onSurface,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_selectedAvatar != null)
                                              InkWell(
                                                onTap: isLoading
                                                    ? null
                                                    : () => setState(
                                                        () => _selectedAvatar =
                                                            null,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 2,
                                                  ),
                                                  child: Text(
                                                    'Remove',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      height: 1.35,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _error,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const Gap(2),
                                        const Text(
                                          'Optional • JPG/PNG max 5MB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            fontWeight: FontWeight.w400,
                                            color: _secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Gap(20),

                            // 3. Form Input Section
                            AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _RegisterInputField(
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    isFocused: _isNameFocused,
                                    prefixIcon: Icons.person_outline,
                                    hintText: 'Full Name',
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                  ),
                                  const Gap(12),
                                  _RegisterInputField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    isFocused: _isUsernameFocused,
                                    prefixIcon: Icons.alternate_email,
                                    hintText: 'Username',
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                  ),
                                  const Gap(12),
                                  _RegisterInputField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    isFocused: _isEmailFocused,
                                    prefixIcon: Icons.mail_outline,
                                    hintText: 'Email Address',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                  ),
                                  const Gap(12),
                                  _RegisterInputField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    isFocused: _isPasswordFocused,
                                    prefixIcon: Icons.lock_outline,
                                    hintText: 'Password (min. 6 chars)',
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    suffix: Semantics(
                                      button: true,
                                      label: _obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(22),
                                        child: SizedBox(
                                          width: 44,
                                          height: 44,
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
                                  ),
                                  const Gap(12),
                                  _RegisterInputField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocusNode,
                                    isFocused: _isConfirmPasswordFocused,
                                    prefixIcon: Icons.lock_outline,
                                    hintText: 'Confirm Password',
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    onSubmitted: (_) {
                                      if (!isLoading) _register();
                                    },
                                    suffix: Semantics(
                                      button: true,
                                      label: _obscureConfirmPassword
                                          ? 'Show confirm password'
                                          : 'Hide confirm password',
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(22),
                                        child: SizedBox(
                                          width: 44,
                                          height: 44,
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
                                  ),
                                ],
                              ),
                            ),

                            const Gap(24),

                            // 4. Primary CTA Button (Pill)
                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryContainer,
                                  foregroundColor: _onPrimary,
                                  disabledBackgroundColor: _primaryContainer
                                      .withValues(alpha: 0.7),
                                  elevation: 0,
                                  shape: const StadiumBorder(),
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
                                          height: 1.3,
                                          fontWeight: FontWeight.w600,
                                          color: _onPrimary,
                                        ),
                                      ),
                              ),
                            ),

                            // 5. Legal Footer
                            const Spacer(),
                            const Gap(20),
                            const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  color: _secondary,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        "By creating an account, you agree to ZieSocial's ",
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: _secondary,
                                      fontWeight: FontWeight.w500,
                                      color: _onSurface,
                                    ),
                                  ),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy.',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: _secondary,
                                      fontWeight: FontWeight.w500,
                                      color: _onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
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

class _RegisterInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final IconData prefixIcon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _RegisterInputField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.prefixIcon,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      height: 52,
      padding: EdgeInsets.only(left: 16, right: suffix != null ? 4 : 16),
      decoration: BoxDecoration(
        color: isFocused
            ? _RegisterViewState._surfaceContainer
            : _RegisterViewState._surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? _RegisterViewState._primary.withValues(alpha: 0.35)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(
              prefixIcon,
              size: 20,
              color: _RegisterViewState._secondary,
            ),
          ),
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
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: _RegisterViewState._onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color: _RegisterViewState._secondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}


