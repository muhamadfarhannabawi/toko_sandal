import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_sandal/core/routes/app_router.dart';
// Pastikan import AuthProvider benar dan tidak ter-hide
import 'package:toko_sandal/features/auth/presentation/provider/auth_provider.dart';
import 'package:toko_sandal/features/auth/presentation/widgets/auth_header.dart';
import 'package:toko_sandal/features/auth/presentation/widgets/custom_buton.dart';
import 'package:toko_sandal/features/auth/presentation/widgets/custom_teks_file.dart';

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
    // Tutup keyboard saat tombol ditekan
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
      // Tampilkan pesan sukses sebelum pindah halaman
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
    // Pantau status loading dari provider
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      // Bungkus dengan Stack untuk overlay loading manual jika LoadingOverlay kustom tidak tersedia
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
                    CustomTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      controller: _nameCtrl,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
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
                      hint: 'Minimal 8 karakter',
                      controller: _passCtrl,
                      obscureText: !_showPass,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_showPass
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                      validator: (v) => (v?.length ?? 0) < 8
                          ? 'Password minimal 8 karakter'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password',
                      controller: _pass2Ctrl,
                      obscureText: !_showPass,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Konfirmasi password wajib diisi';
                        if (v != _passCtrl.text) return 'Password tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: 'Daftar Sekarang',
                      // Matikan tombol jika sedang loading
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
                              context, AppRouter.login),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Indikator loading jika sedang proses
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