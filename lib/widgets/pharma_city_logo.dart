import 'package:flutter/material.dart';

class PharmaCityLogo extends StatelessWidget {
  const PharmaCityLogo({
    super.key,
    required this.primaryColor,
    required this.accentColor,
  });

  final Color primaryColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 110,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 6,
                top: 18,
                child: Transform.rotate(
                  angle: -0.65,
                  child: Container(
                    width: 56,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 22,
                child: Transform.rotate(
                  angle: 0.35,
                  child: Container(
                    width: 46,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(110, 92),
                painter: _PharmaMarkPainter(primaryColor: primaryColor, accentColor: accentColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'PHARMA CITY',
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'GJILAN',
          style: TextStyle(
            color: accentColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }
}

class _PharmaMarkPainter extends CustomPainter {
  _PharmaMarkPainter({required this.primaryColor, required this.accentColor});

  final Color primaryColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final paintAccent = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final pathBlue = Path()
      ..moveTo(size.width * 0.32, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.32, size.height * 0.30, size.width * 0.52, size.height * 0.34)
      ..quadraticBezierTo(size.width * 0.58, size.height * 0.35, size.width * 0.60, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.63, size.height * 0.48, size.width * 0.56, size.height * 0.53)
      ..quadraticBezierTo(size.width * 0.47, size.height * 0.62, size.width * 0.44, size.height * 0.78)
      ..close();

    final pathTeal = Path()
      ..moveTo(size.width * 0.44, size.height * 0.30)
      ..quadraticBezierTo(size.width * 0.56, size.height * 0.34, size.width * 0.66, size.height * 0.50)
      ..quadraticBezierTo(size.width * 0.71, size.height * 0.58, size.width * 0.65, size.height * 0.66)
      ..quadraticBezierTo(size.width * 0.58, size.height * 0.72, size.width * 0.52, size.height * 0.64)
      ..quadraticBezierTo(size.width * 0.46, size.height * 0.56, size.width * 0.44, size.height * 0.44)
      ..close();

    canvas.drawPath(pathBlue, paintPrimary);
    canvas.drawPath(pathTeal, paintAccent);
  }

  @override
  bool shouldRepaint(covariant _PharmaMarkPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor || oldDelegate.accentColor != accentColor;
  }
}

