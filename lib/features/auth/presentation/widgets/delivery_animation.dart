import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Animated delivery van widget for login/signup pages.
/// Shows a moving delivery truck with animated pharmacy elements.
class DeliveryAnimation extends StatefulWidget {
  final double height;

  const DeliveryAnimation({super.key, this.height = 140});

  @override
  State<DeliveryAnimation> createState() => _DeliveryAnimationState();
}

class _DeliveryAnimationState extends State<DeliveryAnimation>
    with TickerProviderStateMixin {
  late AnimationController _truckController;
  late Animation<Offset> _truckAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _pill1Controller;
  late Animation<Offset> _pill1Animation;

  late AnimationController _pill2Controller;
  late Animation<Offset> _pill2Animation;

  late AnimationController _crossController;
  late Animation<double> _crossAnimation;

  @override
  void initState() {
    super.initState();

    // Truck moves from left to right
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _truckAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: _truckController,
      curve: Curves.easeInOut,
    ));

    // Bounce/pulse animation for the truck (vertical)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Floating pill 1
    _pill1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pill1Animation = Tween<Offset>(
      begin: const Offset(-0.15, -0.05),
      end: const Offset(0.15, 0.05),
    ).animate(CurvedAnimation(
      parent: _pill1Controller,
      curve: Curves.easeInOut,
    ));

    // Floating pill 2
    _pill2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pill2Animation = Tween<Offset>(
      begin: const Offset(0.1, -0.08),
      end: const Offset(-0.1, 0.08),
    ).animate(CurvedAnimation(
      parent: _pill2Controller,
      curve: Curves.easeInOut,
    ));

    // Cross rotation / pulse
    _crossController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _crossAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _crossController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _truckController.dispose();
    _pulseController.dispose();
    _pill1Controller.dispose();
    _pill2Controller.dispose();
    _crossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Road line
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _DashedLinePainter(),
            ),
          ),
          // Floating pill 1
          AnimatedBuilder(
            animation: _pill1Controller,
            builder: (context, child) {
              return Positioned(
                top: 8,
                left: 30,
                child: Transform.translate(
                  offset: Offset(
                    _pill1Animation.value.dx * 100,
                    _pill1Animation.value.dy * 100,
                  ),
                  child: _buildPill(Colors.pink, Colors.pink.shade200),
                ),
              );
            },
          ),
          // Floating pill 2
          AnimatedBuilder(
            animation: _pill2Controller,
            builder: (context, child) {
              return Positioned(
                top: 40,
                right: 40,
                child: Transform.translate(
                  offset: Offset(
                    _pill2Animation.value.dx * 80,
                    _pill2Animation.value.dy * 80,
                  ),
                  child: _buildPill(Colors.orange, Colors.orange.shade200),
                ),
              );
            },
          ),
          // Pharmacy cross
          AnimatedBuilder(
            animation: _crossController,
            builder: (context, child) {
              return Positioned(
                top: 2,
                right: 20,
                child: Transform.scale(
                  scale: _crossAnimation.value,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          // Delivery truck
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_truckController, _pulseController]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _truckAnimation.value.dx * MediaQuery.of(context).size.width,
                    _pulseAnimation.value,
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Truck body
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 70,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00A36C), Color(0xFF008F5E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Front cab
                                Container(
                                  width: 24,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF007A50),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                // Cargo area with tiny package icon
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: 20,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(
                                        Icons.medication,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Wheels
                        Positioned(
                          bottom: -3,
                          left: 12,
                          child: _buildWheel(),
                        ),
                        Positioned(
                          bottom: -3,
                          right: 12,
                          child: _buildWheel(),
                        ),
                        // Cross on top of truck
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              size: 10,
                              color: Color(0xFF00A36C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(Color c1, Color c2) {
    return Container(
      width: 20,
      height: 10,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c1, c2],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: c1.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E4A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
    );
  }
}

/// Dashed line painter for the road
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
