import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/view/login_view.dart';
import 'package:ziesocial/viewmodel/register_viewmodel.dart';
import 'package:ziesocial/widget/app_button.dart';
import 'package:ziesocial/widget/app_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Added: Re-ordering & menambahkan _confirmPasswordController
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Added: State untuk toggle visibility (mata) pada password dan confirm password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Added: Konstanta warna dan style agar konsisten dengan gambar UI
  static const primaryColor = Color(0xFF4C4DDC);
  static const inputBgColor = Color(0xFFF3F4F6);
  static const borderColor = Color(0xFFE5E7EB);
  static const iconColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi.')));
      return;
    }

    // Fixed: Perbaikan typo teks
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Confirm Password tidak sama.'),
        ),
      );
      return;
    }

    final viewModel = context.read<RegisterViewModel>();
    final success = await viewModel.register(
      username: username,
      email: email,
      name: name,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.successMessage ?? 'Registrasi berhasil.'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else {
      final errorMessage = viewModel.errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Registrasi gagal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RegisterViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: primaryColor,
                    size: 24,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    }
                  },
                ),
              ),

              const Gap(24),

              const Text(
                'ZieSocial',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),

              const Gap(8),

              const Text(
                "Join the community. Let's get started.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),

              const Gap(24),

              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Action untuk upload foto
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const Gap(8),
                    const Text(
                      'Upload Photo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(24),

              AppTextField(
                controller: _nameController,
                labelText: '',
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, color: iconColor),
                backgroundColor: inputBgColor,
                borderColor: borderColor,
                borderRadius: 12,
              ),

              const Gap(12),

              AppTextField(
                controller: _usernameController,
                labelText: '',
                hintText: 'Username',
                prefixIcon: const Icon(Icons.alternate_email, color: iconColor),
                backgroundColor: inputBgColor,
                borderColor: borderColor,
                borderRadius: 12,
              ),

              const Gap(12),

              AppTextField(
                controller: _emailController,
                labelText: '',
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: iconColor),
                backgroundColor: inputBgColor,
                borderColor: borderColor,
                borderRadius: 12,
              ),

              const Gap(12),

              // Fixed: Perbaikan suffixIcon menggunakan IconButton
              AppTextField(
                controller: _passwordController,
                labelText: '',
                hintText: 'Password',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, color: iconColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                backgroundColor: inputBgColor,
                borderColor: borderColor,
                borderRadius: 12,
              ),

              const Gap(12),

              AppTextField(
                controller: _confirmPasswordController,
                labelText: '',
                hintText: 'Confirm Password',
                obscureText: _obscureConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline, color: iconColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                backgroundColor: inputBgColor,
                borderColor: borderColor,
                borderRadius: 12,
              ),

              const Gap(24),

              AppButton(
                text: 'Create Account',
                isLoading: isLoading,
                onPressed: _register,
                backgroundColor: primaryColor,
                borderRadius: 12,
              ),

              const Gap(24),

              // Fixed: Menambahkan spasi setelah tanda tanya
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
