import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/view/home_view.dart';
import 'package:ziesocial/view/register_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  // Design System ZieSocial
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _surfaceVariant = Color(0xFFE5E2E1);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryContainer = Color(0xFF6657E8);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _error = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChanged);
    _passwordFocusNode.addListener(_onPasswordFocusChanged);
  }

  void _onEmailFocusChanged() {
    if (mounted) {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    }
  }

  void _onPasswordFocusChanged() {
    if (mounted) {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _passwordFocusNode.removeListener(_onPasswordFocusChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan password wajib diisi.');
      return;
    }

    final success = await context.read<LoginViewModel>().login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      final errorMessage = context.read<LoginViewModel>().errorMessage;
      _showSnackBar(errorMessage ?? 'Login Gagal.');
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoginViewModel>().isLoading;

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
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Header Section (Rata Tengah)
                            const Text(
                              'Sign in',
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
                                  'New user? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                    color: _secondary,
                                  ),
                                ),
                                InkWell(
                                  onTap: isLoading ? null : _navigateToRegister,
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      'Create an account',
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

                            const Gap(28),

                            // 2. Form Input Section
                            AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _LoginInputField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    isFocused: _isEmailFocused,
                                    prefixIcon: Icons.mail_outline,
                                    hintText: 'Email Address',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                  ),
                                  const Gap(14),
                                  _LoginInputField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    isFocused: _isPasswordFocused,
                                    prefixIcon: Icons.lock_outline,
                                    hintText: 'Password',
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onSubmitted: (_) {
                                      if (!isLoading) _login();
                                    },
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
                                ],
                              ),
                            ),

                            const Gap(12),

                            // Forgot Password Link (Rata Tengah)
                            Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                      color: _onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const Gap(28),

                            // 3. Primary CTA Button (Pill)
                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _login,
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
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.3,
                                          fontWeight: FontWeight.w600,
                                          color: _onPrimary,
                                        ),
                                      ),
                              ),
                            ),

                            const Gap(24),

                            // 4. Divider ("or")
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: _surfaceVariant,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.3,
                                      fontWeight: FontWeight.w400,
                                      color: _secondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: _surfaceVariant,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),

                            const Gap(24),

                            // 5. Social Login Buttons (Stacked Full-Width Pills)
                            _SocialAuthButton(
                              onTap: isLoading ? null : () {},
                              icon: const SizedBox(
                                width: 18,
                                height: 18,
                                child: CustomPaint(
                                  painter: _GoogleLogoPainter(),
                                ),
                              ),
                              label: 'Continue with Google',
                            ),
                            const Gap(12),
                            _SocialAuthButton(
                              onTap: isLoading ? null : () {},
                              icon: const Icon(
                                Icons.apple,
                                size: 22,
                                color: _onSurface,
                              ),
                              label: 'Continue with Apple',
                            ),

                            // 6. Legal Footer
                            const Spacer(),
                            const Gap(24),
                            const _AuthLegalFooter(
                              prefixText:
                                  "By signing in with an account, you agree to ZieSocial's ",
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

class _LoginInputField extends StatelessWidget {
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

  const _LoginInputField({
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
            ? _LoginViewState._surfaceContainer
            : _LoginViewState._surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? _LoginViewState._primary.withValues(alpha: 0.35)
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
              color: _LoginViewState._secondary,
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
                color: _LoginViewState._onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color: _LoginViewState._secondary,
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

class _SocialAuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String label;

  const _SocialAuthButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Material(
        color: _LoginViewState._surfaceContainerLowest,
        shape: const StadiumBorder(
          side: BorderSide(color: _LoginViewState._surfaceVariant, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: _LoginViewState._surfaceContainerLow,
          splashColor: _LoginViewState._surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(child: icon),
                  ),
                ),
                const Gap(10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: _LoginViewState._onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthLegalFooter extends StatelessWidget {
  final String prefixText;

  const _AuthLegalFooter({required this.prefixText});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 12,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: _LoginViewState._secondary,
        ),
        children: [
          TextSpan(text: prefixText),
          const TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: _LoginViewState._secondary,
              fontWeight: FontWeight.w500,
              color: _LoginViewState._onSurface,
            ),
          ),
          const TextSpan(text: ' and '),
          const TextSpan(
            text: 'Privacy Policy.',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: _LoginViewState._secondary,
              fontWeight: FontWeight.w500,
              color: _LoginViewState._onSurface,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(23.745, 12.27)
      ..cubicTo(23.745, 11.57, 23.685, 10.87, 23.555, 10.20)
      ..lineTo(12, 10.20)
      ..lineTo(12, 14.71)
      ..lineTo(18.6, 14.71)
      ..cubicTo(18.31, 16.23, 17.46, 17.51, 16.2, 18.37)
      ..lineTo(16.2, 21.42)
      ..lineTo(20.08, 21.42)
      ..cubicTo(22.35, 19.33, 23.745, 16.25, 23.745, 12.27)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(12, 24)
      ..cubicTo(15.24, 24, 17.95, 22.92, 19.93, 21.09)
      ..lineTo(16.05, 18.04)
      ..cubicTo(14.97, 18.76, 13.60, 19.20, 12, 19.20)
      ..cubicTo(8.88, 19.20, 6.23, 17.10, 5.28, 14.27)
      ..lineTo(1.25, 14.27)
      ..lineTo(1.25, 17.42)
      ..cubicTo(3.26, 21.36, 7.34, 24, 12, 24)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(5.28, 14.27)
      ..cubicTo(5.03, 13.55, 4.90, 12.78, 4.90, 12.0)
      ..cubicTo(4.90, 11.22, 5.03, 10.45, 5.28, 9.73)
      ..lineTo(5.28, 6.58)
      ..lineTo(1.25, 6.58)
      ..cubicTo(0.45, 8.17, 0, 9.97, 0, 12.0)
      ..cubicTo(0, 14.03, 0.45, 15.83, 1.25, 17.42)
      ..lineTo(5.28, 14.27)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Red
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(12, 4.75)
      ..cubicTo(13.77, 4.75, 15.35, 5.36, 16.6, 6.55)
      ..lineTo(20.02, 3.13)
      ..cubicTo(17.95, 1.19, 15.24, 0, 12, 0)
      ..cubicTo(7.34, 0, 3.26, 2.64, 1.25, 6.58)
      ..lineTo(5.28, 9.73)
      ..cubicTo(6.23, 6.90, 8.88, 4.75, 12, 4.75)
      ..close();
    canvas.drawPath(redPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

