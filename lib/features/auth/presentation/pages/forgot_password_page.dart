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

final forgotPasswordProvider = ChangeNotifierProvider<ForgotPasswordNotifier>((ref) => ForgotPasswordNotifier(ref));

class ForgotPasswordNotifier extends ChangeNotifier {
  final Ref _ref;
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  bool _isSent = false;

  ForgotPasswordNotifier(this._ref);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSent => _isSent;

  void clearError() { _error = null; notifyListeners(); }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.sendPasswordReset(emailController.text.trim());
      _isSent = true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found': _error = 'Nuk u gjet asnjë llogari me këtë email.';
        case 'invalid-email': _error = 'Ju lutem shkruani një email valid.';
        case 'network-request-failed': _error = 'Nuk ka lidhje interneti.';
        default: _error = 'Dërgimi i email-it dështoi. Ju lutem provoni përsëri.';
      }
    } catch (e) {
      _error = 'Ndodhi një gabim i papritur.';
    }
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}

class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);

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
            key: state.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: Text('Rivendos Fjalëkalimin', style: AppTextStyles.headlineLarge)),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Shkruani email-in tuaj dhe ne do t\'ju dërgojmë një lidhje për rivendosje',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

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
                  child: state.error != null
                      ? Container(
                          key: const ValueKey('error'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
                              const SizedBox(width: 10),
                              Expanded(child: Text(state.error!, style: const TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'Poppins'))),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Success banner
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.isSent
                      ? Container(
                          key: const ValueKey('success'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Lidhja u dërgua! Kontrolloni email-in tuaj.',
                                  style: const TextStyle(color: AppColors.success, fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Email Field
                AppTextField(
                  controller: state.emailController,
                  label: AppStrings.email,
                  hintText: 'Shkruani email-in tuaj',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.email,
                ),
                const SizedBox(height: 28),

                // Send Reset Button
                AppButton(
                  label: state.isSent ? 'Ridërgo Lidhjen' : AppStrings.sendResetLink,
                  isLoading: state.isLoading,
                  onPressed: () => ref.read(forgotPasswordProvider).submit(),
                ),

                if (state.isSent) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Kthehu te Hyrja',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
