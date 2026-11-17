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

  // Design tokens sesuai konfigurasi Tailwind pada HTML
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _secondary = Color(0xFF5E5D6C);
  static const Color _primary = Color(0xFF4D3BCE);
  static const Color _primaryContainer = Color(0xFF6657E8);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainer = Color(0xFFF0EDED);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceVariant = Color(0xFFE5E2E1);

  static const String _brandLogoUrl =
      'https://lh3.googleusercontent.com/aida/ALJJyrAfMs2ItwwCkd5S8GKnTKuYjyXKj8uj6XczHo5Kkahl1P0R2pCUqhdIyBuBiUKT0MAjFiZVsByNRJTFtlf7FuouANoUWjcAeNwiF9hxaWgN-0B81jMz39JlOwWlxmNMUSmZsj1llNc0BrxSoFljE0s7zrcnmc9D9QNWoNVIcmcTMssBiMeN3cg27oQvhb4wKfEzKaWwoH-z6RCVc3_5Win7EN8-OpOoPS5z6Ld-Iy7wmg';

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi.'),
        ),
      );
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
        MaterialPageRoute(
          builder: (context) => const HomeView(),
        ),
      );
    } else {
      final errorMessage = context.read<LoginViewModel>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Login Gagal.'),
        ),
      );
    }
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
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Branding Header
                        const Gap(24),
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
                        const Gap(32),

                        // Welcome Section
                        const Text(
                          'Welcome back',
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
                          'Sign in to continue sharing your moments.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 21 / 14,
                            fontWeight: FontWeight.w400,
                            color: _secondary,
                          ),
                        ),
                        const Gap(24),

                        // Form Container
                        // Email Input Field
                        const Text(
                          'Email address',
                          style: TextStyle(
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
                            color: _isEmailFocused
                                ? _surfaceContainer
                                : _surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                size: 20,
                                color: _secondary,
                              ),
                              const Gap(12),
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 21 / 14,
                                    fontWeight: FontWeight.w400,
                                    color: _onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                    hintStyle: TextStyle(
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
                            ],
                          ),
                        ),
                        const Gap(16),

                        // Password Input Field
                        const Text(
                          'Password',
                          style: TextStyle(
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
                            color: _isPasswordFocused
                                ? _surfaceContainer
                                : _surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: _secondary,
                              ),
                              const Gap(12),
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 21 / 14,
                                    fontWeight: FontWeight.w400,
                                    color: _onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
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
                              const Gap(8),
                              GestureDetector(
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
                            ],
                          ),
                        ),
                        const Gap(20),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                letterSpacing: 0.12,
                                fontWeight: FontWeight.w500,
                                color: _primary,
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
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryContainer,
                              foregroundColor: _onPrimary,
                              disabledBackgroundColor:
                                  _primaryContainer.withValues(alpha: 0.7),
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
                                    'Log in',
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

                        // Social Divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: _surfaceVariant,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 14 / 11,
                                  letterSpacing: 0.22,
                                  fontWeight: FontWeight.w400,
                                  color: _secondary,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: _surfaceVariant,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),

                        // Social Login Actions
                        Row(
                          children: [
                            Expanded(
                              child: _SocialLoginButton(
                                onTap: () {},
                                icon: const Icon(
                                  Icons.apple,
                                  size: 20,
                                  color: _onSurface,
                                ),
                                label: 'Apple',
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _SocialLoginButton(
                                onTap: () {},
                                icon: const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CustomPaint(
                                    painter: _GoogleLogoPainter(),
                                  ),
                                ),
                                label: 'Google',
                              ),
                            ),
                          ],
                        ),
                        const Gap(32),

                        // Registration Footer (mt-auto pt-space-md)
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 21 / 14,
                                  fontWeight: FontWeight.w400,
                                  color: _secondary,
                                ),
                              ),
                              const Gap(4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterView(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Create account',
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

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String label;

  const _SocialLoginButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _LoginViewState._surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: _LoginViewState._surfaceContainerLow,
          splashColor: _LoginViewState._surfaceContainerLow,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const Gap(8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  height: 18 / 14,
                  fontWeight: FontWeight.w500,
                  color: _LoginViewState._onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
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
