import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmacity/features/auth/presentation/pages/login_page.dart';
import 'package:pharmacity/features/auth/presentation/pages/register_page.dart';
import 'package:pharmacity/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:pharmacity/features/seed/presentation/pages/seed_data_page.dart';
import 'package:pharmacity/features/home/presentation/pages/home_page.dart';
import 'package:pharmacity/features/products/presentation/pages/product_list_page.dart';
import 'package:pharmacity/features/products/presentation/pages/product_detail_page.dart';
import 'package:pharmacity/features/categories/presentation/pages/categories_page.dart';
import 'package:pharmacity/features/products/presentation/pages/search_page.dart';
import 'package:pharmacity/features/cart/presentation/pages/cart_page.dart';
import 'package:pharmacity/features/cart/presentation/pages/checkout_page.dart';
import 'package:pharmacity/features/orders/presentation/pages/order_history_page.dart';
import 'package:pharmacity/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:pharmacity/features/map/presentation/pages/pharmacy_map_page.dart';
import 'package:pharmacity/features/profile/presentation/pages/profile_page.dart';
import 'package:pharmacity/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:pharmacity/features/admin/presentation/pages/admin_products_page.dart';
import 'package:pharmacity/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:pharmacity/features/admin/presentation/pages/admin_payments_page.dart';

import 'package:pharmacity/features/notifications/presentation/pages/notifications_page.dart';
import 'package:pharmacity/core/constants/app_colors.dart';
import 'package:pharmacity/features/auth/presentation/providers/auth_providers.dart';

// Firebase auth state stream provider
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// GoRouter provider with auth redirect
final goRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(firebaseAuthStateProvider).valueOrNull != null;

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';
      final isSeed = state.matchedLocation == '/seed-data';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (isSplash || isSeed) return null;
      if (isAdminRoute && !isLoggedIn) return '/auth/login';
      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) {
        final auth = FirebaseAuth.instance;
        if (auth.currentUser != null) {
          final firestore = FirebaseFirestore.instance;
          try {
            final doc = await firestore
                .collection('users')
                .doc(auth.currentUser!.uid)
                .get();
            if (doc.exists && doc.data()?['role'] == 'admin') {
              return '/admin';
            }
          } catch (_) {}
        }
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (c, s) =>
            _buildPageTransition(child: const _SplashScreen()),
      ),
      GoRoute(
        path: '/seed-data',
        pageBuilder: (c, s) =>
            _buildPageTransition(child: const SeedDataPage()),
      ),
      GoRoute(
        path: '/auth/login',
        pageBuilder: (c, s) => _buildPageTransition(child: const LoginPage()),
      ),
      GoRoute(
        path: '/auth/signup',
        pageBuilder: (c, s) =>
            _buildPageTransition(child: const RegisterPage()),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (c, s) =>
            _buildPageTransition(child: const ForgotPasswordPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
              path: '/home',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const HomePage())),
          GoRoute(
              path: '/products',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const ProductListPage())),
          GoRoute(
            path: '/products/:id',
            pageBuilder: (c, s) => _buildPageTransition(
                child: ProductDetailPage(productId: s.pathParameters['id']!)),
          ),
          GoRoute(
              path: '/categories',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const CategoriesPage())),
          GoRoute(
              path: '/search',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const SearchPage())),
          GoRoute(
              path: '/cart',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const CartPage())),
          GoRoute(
              path: '/checkout',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const CheckoutPage())),
          GoRoute(
              path: '/orders',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const OrderHistoryPage())),
          GoRoute(
            path: '/orders/:id/confirmation',
            pageBuilder: (c, s) => _buildPageTransition(
                child: OrderConfirmationPage(orderId: s.pathParameters['id']!)),
          ),
          GoRoute(
              path: '/map',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const PharmacyMapPage())),
          GoRoute(
              path: '/profile',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const ProfilePage())),
          GoRoute(
              path: '/notifications',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const NotificationsPage())),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => _AdminShell(child: child),
        routes: [
          GoRoute(
              path: '/admin',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const AdminDashboardPage())),
          GoRoute(
              path: '/admin/products',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const AdminProductsPage())),
          GoRoute(
              path: '/admin/orders',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const AdminOrdersPage())),
          GoRoute(
              path: '/admin/payments',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const AdminPaymentsPage())),
          GoRoute(
              path: '/admin/notifications',
              pageBuilder: (c, s) =>
                  _buildPageTransition(child: const NotificationsPage(isAdmin: true))),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Faqja nuk u gjet: ${state.uri}')),
    ),
  );
});

Page<dynamic> _buildPageTransition({required Widget child}) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

// ─── Splash Screen ───────────────────────────────────────────────────────────

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with TickerProviderStateMixin {
  bool _navigated = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: const Offset(-8, 0),
      end: const Offset(8, 0),
    ).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_navigated) {
        _navigated = true;
        GoRouter.of(context).go('/auth/login');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(firebaseAuthStateProvider, (_, next) {
      if (next.hasValue && !_navigated) {
        _navigated = true;
        final user = next.value;
        if (user != null) {
          GoRouter.of(context).go('/home');
        } else {
          GoRouter.of(context).go('/auth/login');
        }
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F8F2), Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -50,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.local_pharmacy,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00A36C), Color(0xFF007A50)],
                      ).createShader(bounds),
                      child: const Text(
                        'PharmaCity',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Shpërndajmë produkte farmaceutike për klientët në Gjilan',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          height: 1.4,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) => Transform.translate(
                        offset: _floatAnimation.value,
                        child: Container(
                          width: 70,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping,
                                  size: 18, color: AppColors.primary),
                              SizedBox(width: 4),
                              Icon(Icons.medication,
                                  size: 16, color: AppColors.primaryLight),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Text(
                  'PharmaCity Gjilan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint.withValues(alpha: 0.5),
                    letterSpacing: 1.5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main Shell with User Bottom Navigation ──────────────────────────────────

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        unselectedLabelStyle:
            const TextStyle(fontSize: 11, fontFamily: 'Poppins'),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Ballina'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded), label: 'Kërko'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded), label: 'Harta'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded), label: 'Shporta'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profili'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/map')) return 2;
    if (location.startsWith('/cart')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
      case 1:
        GoRouter.of(context).go('/search');
      case 2:
        GoRouter.of(context).go('/map');
      case 3:
        GoRouter.of(context).go('/cart');
      case 4:
        GoRouter.of(context).go('/profile');
    }
  }
}

// ─── Admin Shell with Admin Bottom Navigation ────────────────────────────────

class _AdminShell extends ConsumerWidget {
  const _AdminShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Paneli',
                    isSelected: _isCurrent('/admin', context),
                    onTap: () => GoRouter.of(context).go('/admin'),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'Produktet',
                    isSelected: _isCurrent('/admin/products', context),
                    onTap: () => GoRouter.of(context).go('/admin/products'),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Porositë',
                    isSelected: _isCurrent('/admin/orders', context),
                    onTap: () => GoRouter.of(context).go('/admin/orders'),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.payments_rounded,
                    label: 'Pagesat',
                    isSelected: _isCurrent('/admin/payments', context),
                    onTap: () => GoRouter.of(context).go('/admin/payments'),
                  ),
                ),
                Expanded(
                  child: _AdminNavItem(
                    icon: Icons.logout_rounded,
                    label: 'Dil',
                    isSelected: false,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Dilni nga paneli?'),
                          content: const Text('Jeni të sigurt që doni të dilni nga panela admin?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Anulo', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Dil', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) {
                          GoRouter.of(context).go('/auth/login');
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isCurrent(String route, BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (route == '/admin' && location == '/admin') return true;
    if (route != '/admin' && location.startsWith(route)) return true;
    return false;
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
