import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../widgets/auth_background.dart';
import '../widgets/pill_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    _showSnack('Regjistrimi u krye (demo).');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return Scaffold(
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 76,
                          height: 76,
                          child: CustomPaint(
                            painter: _SimpleLogoPainter(primary: primary, accent: AppColors.secondary),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Krijo Llogari',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 30),
                        PillTextFormField(
                          controller: _nameController,
                          icon: Icons.person_outline,
                          hintText: 'Emri i plotë',
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Ju lutem plotësoni emrin.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        PillTextFormField(
                          controller: _emailController,
                          icon: Icons.mail_outline,
                          hintText: 'Email / Numri telefonit',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Ju lutem plotësoni email ose telefon.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        PillTextFormField(
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hintText: 'Fjalëkalimi',
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          suffix: IconButton(
                            tooltip: _obscurePassword ? 'Shfaq fjalëkalimin' : 'Fshih fjalëkalimin',
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted,
                            ),
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Ju lutem plotësoni fjalëkalimin.';
                            if (v.length < 4) return 'Fjalëkalimi është shumë i shkurtër.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        PillTextFormField(
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline,
                          hintText: 'Konfirmo fjalëkalimin',
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Ju lutem konfirmoni fjalëkalimin.';
                            if (v != _passwordController.text.trim()) return 'Fjalëkalimet nuk përputhen.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                            child: const Text(
                              'Krijo Llogarinë',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, size: 17),
                            label: const Text('Kthehu'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black54,
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleLogoPainter extends CustomPainter {
  _SimpleLogoPainter({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = primary;
    final p2 = Paint()..color = accent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 0.28, height: size.height * 0.9),
        const Radius.circular(18),
      ),
      p2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: size.center(Offset.zero), width: size.width * 0.9, height: size.height * 0.28),
        const Radius.circular(18),
      ),
      p1,
    );
  }

  @override
  bool shouldRepaint(covariant _SimpleLogoPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.accent != accent;
  }
}

