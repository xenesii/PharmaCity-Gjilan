import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
final registerFormProvider = ChangeNotifierProvider<RegisterFormNotifier>((ref) =>
    RegisterFormNotifier(ref));

class RegisterFormNotifier extends ChangeNotifier {
  final Ref _ref;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  RegisterFormNotifier(this._ref);

  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;

  void togglePasswordVisibility() { _obscurePassword = !_obscurePassword; notifyListeners(); }
  void toggleConfirmVisibility() { _obscureConfirm = !_obscureConfirm; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use': _error = 'Një llogari me këtë email ekziston tashmë.';
        case 'weak-password': _error = 'Fjalëkalimi duhet të ketë të paktën 6 karaktere.';
        case 'invalid-email': _error = 'Ju lutem shkruani një email valid.';
        case 'operation-not-allowed': _error = 'Regjistrimi me email/fjalëkalim nuk është i aktivizuar.';
        case 'too-many-requests': _error = 'Shumë përpjekje. Ju lutem provoni më vonë.';
        case 'network-request-failed': _error = 'Nuk ka lidhje interneti.';
        default: _error = 'Regjistrimi dështoi: ${e.message}';
      }
    } catch (e) {
      _error = 'Ndodhi një gabim i papritur. Ju lutem provoni përsëri.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithGoogle() async {
    _isGoogleLoading = true;
    _error = null;
    notifyListeners();

    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.signInWithGoogle();
      _isGoogleLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isGoogleLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(registerFormProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formState.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Logo matching login page
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(65),
                          ),
                          child: const Icon(
                            Icons.local_pharmacy,
                            size: 50,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('Krijo Llogari', style: AppTextStyles.headlineLarge.copyWith(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                  )),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Plotësoni të dhënat për t\'u regjistruar',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 28),

                // Error banner
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: formState.error != null
                      ? Container(
                          key: const ValueKey('error'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
                              const SizedBox(width: 10),
                              Expanded(child: Text(formState.error!, style: const TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'Poppins'))),
                              GestureDetector(
                                onTap: () => ref.read(registerFormProvider).clearError(),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: AppColors.error, size: 16),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Form Fields
                AppTextField(
                  controller: formState.nameController,
                  label: AppStrings.fullName,
                  prefixIcon: const Icon(Icons.person_outlined, size: 20),
                  validator: Validators.fullName,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: formState.emailController,
                  label: AppStrings.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.email,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: formState.phoneController,
                  label: AppStrings.phoneNumber,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: Validators.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: formState.passwordController,
                  label: AppStrings.password,
                  obscureText: formState.obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      formState.obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                    ),
                    onPressed: () => ref.read(registerFormProvider).togglePasswordVisibility(),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: formState.confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  obscureText: formState.obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      formState.obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                    ),
                    onPressed: () => ref.read(registerFormProvider).toggleConfirmVisibility(),
                  ),
                  validator: (v) => Validators.confirmPassword(v, formState.passwordController.text),
                ),
                const SizedBox(height: 28),

                // Sign Up Button
                AppButton(
                  label: AppStrings.signUp,
                  isLoading: formState.isLoading,
                  onPressed: () async {
                    final success = await ref.read(registerFormProvider).submit();
                    if (success && context.mounted) {
                      context.go('/home');
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ose',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderLight)),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: formState.isGoogleLoading
                        ? null
                        : () async {
                            final success = await ref.read(registerFormProvider).signInWithGoogle();
                            if (success && context.mounted) {
                              context.go('/home');
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    icon: formState.isGoogleLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            width: 22, height: 22,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                          ),
                    label: Text(
                      formState.isGoogleLoading ? 'Duke u lidhur...' : AppStrings.googleSignIn,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.haveAccount, style: AppTextStyles.bodyMedium),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.signIn,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
