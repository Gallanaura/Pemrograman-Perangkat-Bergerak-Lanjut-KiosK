import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Header with wavy shape
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 220),
                painter: _WavyHeaderPainter(),
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.only(top: 50, left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ORDER NOW Text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ORD in dark brown
                          Text(
                            'ORD',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF4A2C17),
                              letterSpacing: 3,
                              height: 0.9,
                            ),
                          ),
                          // ER in white, overlapping
                          Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Text(
                              'ER',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3,
                                height: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // NOW in dark brown
                      Text(
                        'NOW',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4A2C17),
                          letterSpacing: 3,
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Payment Buttons
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pay on online button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3806B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Pay on online',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pay on counter button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3806B),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Pay on counter',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavyHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Main dark brown shape
    final paint = Paint()
      ..color = const Color(0xFF6B4423)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.7, 0);
    
    // Create wavy bottom edge
    path.cubicTo(
      size.width * 0.72,
      size.height * 0.2,
      size.width * 0.68,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.72,
      size.height * 0.75,
      size.width * 0.75,
      size.height * 0.85,
      size.width * 0.8,
      size.height * 0.9,
    );
    path.cubicTo(
      size.width * 0.85,
      size.height * 0.95,
      size.width * 0.9,
      size.height * 0.98,
      size.width,
      size.height,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second layer (lighter brown) - slightly offset
    final paint2 = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width * 0.7, 0);
    
    // Similar wavy curve but slightly different
    path2.cubicTo(
      size.width * 0.72,
      size.height * 0.25,
      size.width * 0.68,
      size.height * 0.45,
      size.width * 0.7,
      size.height * 0.65,
    );
    path2.cubicTo(
      size.width * 0.72,
      size.height * 0.8,
      size.width * 0.75,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.95,
    );
    path2.cubicTo(
      size.width * 0.85,
      size.height * 1.0,
      size.width * 0.9,
      size.height * 1.03,
      size.width,
      size.height * 1.05,
    );
    path2.lineTo(size.width, size.height * 1.1);
    path2.lineTo(0, size.height * 1.1);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

