import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacity/core/constants/app_colors.dart';
import 'package:pharmacity/seed_data.dart';

class SeedDataPage extends StatefulWidget {
  const SeedDataPage({super.key});

  @override
  State<SeedDataPage> createState() => _SeedDataPageState();
}

class _SeedDataPageState extends State<SeedDataPage>
    with SingleTickerProviderStateMixin {
  bool _isSeeding = false;
  SeedResult? _result;
  String? _error;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startSeeding() async {
    setState(() {
      _isSeeding = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await seedDatabase();
      if (mounted) {
        setState(() {
          _result = result;
          _isSeeding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F8F2),
              Color(0xFFF0FDF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      onPressed: () => context.go('/auth/login'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Animated icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryGradientStart,
                                AppColors.primaryGradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.storage_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Inicializo t\u00eb Dh\u00ebnat',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Ky funksion do t\u00eb krijoj\u00eb automatikisht '
                    'kategorit\u00eb dhe produktet n\u00eb Firestore.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Info cards
                  _buildInfoCard(
                    Icons.category_rounded,
                    '8 Kategori',
                    'Vitaminat, Kujdesi Personal, Ftohje & Flut, etj.',
                    AppColors.health,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    Icons.medication_rounded,
                    '32 Produkte',
                    'Produkte t\u00eb ndryshme n\u00ebp\u00ebr t\u00eb gjitha kategorit\u00eb',
                    AppColors.primaryLight,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    Icons.warning_amber_rounded,
                    'Kujdes',
                    'N\u00ebse ekzekutohet p\u00ebrs\u00ebri, do t\u00eb krijohen dublikata!',
                    Colors.orange.shade400,
                    isWarning: true,
                  ),
                  const SizedBox(height: 32),

                  // Result or button
                  if (_result != null)
                    _buildResultCard()
                  else if (_error != null)
                    _buildErrorCard()
                  else
                    _buildSeedButton(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle, Color color,
      {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.orange.withValues(alpha: 0.08)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWarning
              ? Colors.orange.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isWarning ? Colors.orange.shade700 : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSeeding ? null : _startSeeding,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSeeding
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Fillo Inicializimin',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGradientStart.withValues(alpha: 0.1),
            AppColors.primaryGradientEnd.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Inicializimi P\u00ebrfundoi!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'U krijuan me sukses ${_result!.total} dokumente n\u00eb Firestore:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(
                Icons.category_rounded,
                '${_result!.categoriesCreated} Kategori',
                AppColors.health,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                Icons.medication_rounded,
                '${_result!.productsCreated} Produkte',
                AppColors.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Shko te Hyrja',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 10),
          const Text(
            'Gabim!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? 'Ndodhi nj\u00eb gabim i panjohur.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Provo P\u00ebrs\u00ebri',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
