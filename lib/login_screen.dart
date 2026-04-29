import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/auth_background.dart';
import 'widgets/pill_text_form_field.dart';
import 'widgets/pharma_city_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showSnack('Kycuar me sukses (demo).');
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final accent = AppColors.secondary;
    final horizontalPadding = MediaQuery.sizeOf(context).width < 420 ? 22.0 : 32.0;

    return Scaffold(
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, right: horizontalPadding),
                    child: TextButton(
                      onPressed: () => _showSnack('Hyrje si mysafir (demo).'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Vazhdo si mysafir', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 84, horizontalPadding, 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PharmaCityLogo(primaryColor: primary, accentColor: accent),
                            const SizedBox(height: 38),
                            PillTextFormField(
                              controller: _loginController,
                              icon: Icons.person_outline,
                              hintText: 'Email / Numri i telefonit',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) return 'Ju lutem plotësoni të dhënat.';
                                if (!v.contains('@') && v.length < 7) {
                                  return 'Shkruani një email ose numër telefoni të vlefshëm.';
                                }
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
                                final v = value ?? '';
                                if (v.trim().isEmpty) return 'Ju lutem plotësoni fjalëkalimin.';
                                if (v.trim().length < 4) return 'Fjalëkalimi është shumë i shkurtër.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text(
                                        'Kyçu',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Keni harruar fjalëkalimin?',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Nuk keni llogari?',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Regjistrohu',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

