import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.profile, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: userAsync.when(
        data: (user) {
          final firebaseUser = auth.currentUser;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Gradient header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientGreen,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => _pickAvatar(context, ref, firebaseUser?.uid ?? ''),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: user.photoUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      (user?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.fullName ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Menu items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: AppStrings.editProfile,
                          subtitle: AppStrings.editProfileSub,
                          onTap: () => _showEditProfile(context, ref, user),
                        ),
                        _ProfileMenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: AppStrings.myOrders,
                          subtitle: AppStrings.noOrdersSubtitle,
                          onTap: () => context.push('/orders'),
                        ),
                        _ProfileMenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.favorite_outline_rounded,
                          title: AppStrings.myFavorites,
                          subtitle: AppStrings.favoritesSub,
                          onTap: () => context.push('/products'),
                        ),
                        _ProfileMenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.location_on_outlined,
                          title: AppStrings.findPharmacy,
                          subtitle: AppStrings.noPharmaciesSub,
                          onTap: () => context.push('/map'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          title: AppStrings.notifications,
                          subtitle: AppStrings.notificationsSub,
                          trailing: Switch(
                            value: ref.watch(notificationsEnabledProvider),
                            onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).state = v,
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: AppColors.white,
                          ),
                        ),
                        _ProfileMenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.language_outlined,
                          title: AppStrings.language,
                          subtitle: AppStrings.english,
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                        ),
                        _ProfileMenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: AppStrings.about,
                          subtitle: AppStrings.version,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Admin card
                if (user?.role == 'admin')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => context.push('/admin'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientGreen,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.adminPanel,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.managePlatform,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context, ref),
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text(
                        AppStrings.logout,
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text(AppStrings.failedToLoadProfile)),
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref, String uid) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ref.read(avatarUploadingProvider.notifier).state = true;
      final url = await ref.read(profileUpdaterProvider).uploadAvatar(uid, file.path);
      if (url != null && context.mounted) {
        ref.invalidate(currentUserProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.avatarUpdated),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: AppColors.primary,
          ),
        );
      }
      if (context.mounted) {
        ref.read(avatarUploadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.logout),
        content: Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.logout, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        context.go('/auth/login');
      }
    }
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, dynamic user) {
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final addressCtrl = TextEditingController(text: user?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppStrings.editProfile, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 20),
              AppTextField(
                controller: nameCtrl,
                label: AppStrings.fullName,
                validator: Validators.fullName,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: phoneCtrl,
                label: AppStrings.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: addressCtrl,
                label: AppStrings.address,
                validator: Validators.address,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: AppStrings.save,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;
                  await ref.read(profileUpdaterProvider).updateProfile(
                    uid,
                    fullName: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                  );
                  if (context.mounted) {
                    ref.invalidate(currentUserProvider);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.profileUpdated),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuDivider extends StatelessWidget {
  const _ProfileMenuDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 58),
      child: Divider(height: 1, color: AppColors.borderLight),
    );
  }
}
