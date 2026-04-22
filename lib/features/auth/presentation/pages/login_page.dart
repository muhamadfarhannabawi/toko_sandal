import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_sandal/core/routes/app_router.dart';
// Perbaikan Import: Pastikan nama class Provider sesuai
import 'package:toko_sandal/features/auth/presentation/provider/auth_provider.dart' hide AuthProvider; 
import 'package:toko_sandal/features/auth/presentation/widgets/auth_header.dart';
import 'package:toko_sandal/features/auth/presentation/widgets/custom_buton.dart'; // Typo di file asal? (custom_button)
import 'package:toko_sandal/features/auth/presentation/widgets/custom_teks_file.dart'; 
import 'package:toko_sandal/features/auth/presentation/widgets/divider_with_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // Gunakan dialogContext agar aman
        title: const Text('Reset Password'),
        content: CustomTextField(
          label: 'Email',
          hint: 'Email terdaftar',
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: ctrl.text.trim(),
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email reset password telah dikirim')),
                  );
                }
              } catch (e) {
                // Handle error reset password
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan selector atau watch dengan spesifik
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Stack( // Gunakan Stack jika LoadingOverlay belum ada, atau bungkus dengan widget loading kamu
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const AuthHeader(
                      icon: Icons.lock_open_outlined,
                      title: 'Selamat Datang',
                      subtitle: 'Masuk ke akun Anda untuk melanjutkan',
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: 'Email',
                      hint: 'contoh@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Email wajib diisi';
                        if (!EmailValidator.validate(v!)) {
                          return 'Format email salah';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Masukkan password',
                      controller: _passCtrl,
                      obscureText: !_showPass,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPass ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPasswordDialog(context),
                        child: const Text('Lupa Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      label: 'Masuk',
                      onPressed: isLoading ? null : _loginEmail,
                    ),
                    const SizedBox(height: 20),
                    const DividerWithText(text: 'atau masuk dengan'),
                    const SizedBox(height: 20),
                    // Perbaikan: Gunakan widget GoogleSignIn yang ada
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text('Google Sign In'),
                        onPressed: isLoading ? null : _loginGoogle,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? '),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            AppRouter.register,
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}