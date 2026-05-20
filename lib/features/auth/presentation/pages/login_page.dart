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
final loginFormProvider =
    ChangeNotifierProvider<LoginFormNotifier>((ref) => LoginFormNotifier(ref));

class LoginFormNotifier extends ChangeNotifier {
  final Ref _ref;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  bool _obscurePassword = true;

  LoginFormNotifier(this._ref);

  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.signIn(emailController.text.trim(), passwordController.text);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getFriendlyError(e.code);
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

  String _getFriendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nuk u gjet asnjë llogari me këtë email.';
      case 'wrong-password':
        return 'Fjalëkalimi i gabuar. Ju lutem provoni përsëri.';
      case 'invalid-email':
        return 'Ju lutem shkruani një email valid.';
      case 'user-disabled':
        return 'Kjo llogari është çaktivizuar.';
      case 'too-many-requests':
        return 'Shumë përpjekje. Ju lutem provoni më vonë.';
      case 'network-request-failed':
        return 'Nuk ka lidhje interneti. Ju lutem kontrolloni rrjetin.';
      case 'invalid-credential':
        return 'Email ose fjalëkalim i gabuar.';
      default:
        return 'Hyrja dështoi: $code';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formState.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Premium Logo Section — logo already has PharmaCity text
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
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
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(110),
                          ),
                          child: const Icon(
                            Icons.local_pharmacy,
                            size: 80,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Albanian slogan
                const Center(
                  child: Text(
                    'Shëndeti juaj, përparësia jonë',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Premium Error Banner
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
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: AppColors.error, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  formState.error!,
                                  style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    ref.read(loginFormProvider).clearError(),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: AppColors.error, size: 16),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Email Field
                AppTextField(
                  controller: formState.emailController,
                  label: AppStrings.email,
                  hintText: 'Shkruani email-in tuaj',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.email,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 18),

                // Password Field
                AppTextField(
                  controller: formState.passwordController,
                  label: AppStrings.password,
                  hintText: 'Shkruani fjalëkalimin',
                  obscureText: formState.obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      formState.obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                    ),
                    onPressed: () =>
                        ref.read(loginFormProvider).togglePasswordVisibility(),
                  ),
                  validator: Validators.password,
                  autofillHints: const [AutofillHints.password],
                ),
                const SizedBox(height: 4),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/auth/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Login Button
                AppButton(
                  label: AppStrings.signIn,
                  isLoading: formState.isLoading,
                  onPressed: () async {
                    final success = await ref.read(loginFormProvider).submit();
                    if (success && context.mounted) {
                      // Kontrollo nëse përdoruesi është admin
                      final auth = FirebaseAuth.instance;
                      if (auth.currentUser != null) {
                        final repo = ref.read(authRepositoryProvider);
                        final user =
                            await repo.getUserById(auth.currentUser!.uid);
                        if (user?.role == 'admin' && context.mounted) {
                          context.go('/admin');
                          return;
                        }
                      }
                      if (context.mounted) {
                        context.go('/home');
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppColors.borderLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ose',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                      ),
                    ),
                    const Expanded(
                        child: Divider(color: AppColors.borderLight)),
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
                            final success = await ref
                                .read(loginFormProvider)
                                .signInWithGoogle();
                            if (success && context.mounted) {
                              final auth = FirebaseAuth.instance;
                              if (auth.currentUser != null) {
                                final repo = ref.read(authRepositoryProvider);
                                final user = await repo
                                    .getUserById(auth.currentUser!.uid);
                                if (user?.role == 'admin' && context.mounted) {
                                  context.go('/admin');
                                  return;
                                }
                              }
                              if (context.mounted) {
                                context.go('/home');
                              }
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side:
                          const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    icon: formState.isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          )
                        : Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            width: 22,
                            height: 22,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.g_mobiledata,
                                size: 28,
                                color: Colors.red),
                          ),
                    label: Text(
                      formState.isGoogleLoading
                          ? 'Duke u lidhur...'
                          : AppStrings.googleSignIn,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => context.push('/auth/signup'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.signUp,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
