import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:ziesocial/view/home_view.dart';
import 'package:ziesocial/view/register_view.dart';
import 'package:ziesocial/viewmodel/login_viewmodel.dart';
import 'package:ziesocial/widget/app_button.dart';
import 'package:ziesocial/widget/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Added: State untuk toggle visibility password
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email dan password wajib diisi.',
          ),
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
          builder:(context) => const HomeView(),
        ),
      );
    } else {
      final errorMessage =
      context.read<LoginViewModel>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ?? 'Login Gagal.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoginViewModel>().isLoading;

    // Definisikan warna utama agar konsisten di seluruh aplikasi
    const primaryColor = Color(0xFF5A57D3);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card( // Menggunakan Card untuk container putih dengan shadow
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ZieSocial',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: primaryColor, // Warna teks 'ZieSocial' sesuai dengan warna utama
                          ),
                        ),

                        const Gap(8),
                        const Text(
                          'Welcome back. Please enter your details.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),

                        const Gap(24),

                        // Input Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const Gap(8),
                        AppTextField(
                          controller: _emailController,
                          labelText: '', // Tidak pakai label text di dalam input field
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B7280),),
                          backgroundColor: const Color(0xFFF9FAFB),
                          borderColor: const Color(0xFFE5E7EB),
                          borderRadius: 12,
                        ),

                        const Gap(16),

                        // Input Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const Gap(8),
                        AppTextField(
                          controller: _passwordController,
                          labelText: '',
                          hintText: 'Enter your password',
                          obscureText: _obscurePassword, // Fixed: menggunakan variable state
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280),),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.visibility_outlined, color: Color(0xFF6B7280),),
                            onPressed: () {
                              // Fixed: Logika toggle visibility password
                              setState( () {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          backgroundColor: const Color(0xFFF9FAFB),
                          borderColor: const Color(0xFFE5E7EB),
                          borderRadius: 12,
                        ),

                        const Gap(16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Implementasikan logika untuk "Forgot Password"
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                        const Gap(16),

                        // Tombol Login
                        AppButton(
                          text: 'Login',
                          isLoading: isLoading,
                          onPressed: _login,
                          backgroundColor: primaryColor,
                          borderRadius: 12,
                        ),

                        const Gap(32),

                        // Seperator
                        const Divider(color: Color(0xFFE5E7EB),),

                        const Gap(24),

                        // Create an Account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                            const Gap(4),
                            GestureDetector(
                              onTap: () {
                                // Fixed: Navigasi ke halaman register
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterView(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create an Account',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
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