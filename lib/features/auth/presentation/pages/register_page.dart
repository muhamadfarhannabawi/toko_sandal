import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_sandal/core/routes/app_router.dart';
import 'package:toko_sandal/features/auth/presentation/provider/auth_provider.dart';
import 'package:toko_sandal/features/auth/presentation/widgets/auth_header.dart';

// ✅ PERBAIKAN IMPORT
import 'package:toko_sandal/features/auth/presentation/widgets/custom_button.dart';
import 'package:toko_sandal/features/auth/presentation/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _showPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan cek email Anda.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Pendaftaran gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Scaffold(
      body: Stack(
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
                      icon: Icons.person_add_alt_1,
                      title: 'Buat Akun Baru',
                      subtitle: 'Lengkapi data diri Anda untuk mendaftar',
                    ),

                    const SizedBox(height: 32),

                    /// NAMA
                    CustomTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      controller: _nameCtrl,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    /// EMAIL
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

                    /// PASSWORD
                    CustomTextField(
                      label: 'Password',
                      hint: 'Minimal 8 karakter',
                      controller: _passCtrl,
                      obscureText: !_showPass,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPass
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                      validator: (v) => (v?.length ?? 0) < 8
                          ? 'Password minimal 8 karakter'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    /// KONFIRMASI PASSWORD
                    CustomTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password',
                      controller: _pass2Ctrl,
                      obscureText: !_showPass,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) {
                        if (v?.isEmpty ?? true) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (v != _passCtrl.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    /// BUTTON
                    CustomButton(
                      label: 'Daftar Sekarang',
                      onPressed: isLoading ? null : _register,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? '),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            AppRouter.login,
                          ),
                          child: const Text(
                            'Masuk',
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

          /// LOADING OVERLAY
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}