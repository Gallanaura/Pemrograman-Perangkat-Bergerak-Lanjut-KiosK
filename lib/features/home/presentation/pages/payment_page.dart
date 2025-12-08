import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/core/utils/user_preferences.dart';
import 'package:kiosk/features/auth/data/repositories/auth_repository.dart';
import 'package:kiosk/features/home/data/models/cart_item.dart';
import 'package:kiosk/features/home/data/repositories/order_repository.dart';
import 'package:kiosk/features/home/data/repositories/product_repository.dart';
import 'package:kiosk/features/home/presentation/pages/home_page.dart';
import 'package:kiosk/features/home/presentation/pages/payment_process_page.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final int totalPrice;
  final String tableNumber;
  final String notes;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.tableNumber,
    required this.notes,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final OrderRepository _orderRepository = OrderRepository();
  final AuthRepository _authRepository = AuthRepository();
  bool _isSaving = false;

  Future<void> _saveOrder(String paymentMethod) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final userId = await UserPreferences.getUserId() ?? 1;
      
      // Get user info for display
      final user = await _authRepository.getUserById(userId);
      final userName = user?['username'] as String? ?? 'Guest';
      
      // Get product IDs from cart items
      final productRepository = ProductRepository();
      final allProducts = await productRepository.getAllProducts();
      
      final List<Map<String, dynamic>> orderItems = [];
      for (var cartItem in widget.cartItems) {
        final product = allProducts.firstWhere(
          (p) => p['name'] == cartItem.drink.name,
          orElse: () => <String, dynamic>{'id': 1},
        );
        orderItems.add({
          'product_id': product['id'] as int,
          'quantity': cartItem.quantity,
          'price': cartItem.drink.price,
        });
      }

      // Determine order status based on payment method
      final orderStatus = paymentMethod == 'Pay on counter' ? 'pending' : 'completed';

      final orderId = await _orderRepository.createOrder(
        userId: userId,
        totalPrice: widget.totalPrice,
        tableNumber: widget.tableNumber,
        notes: widget.notes,
        paymentMethod: paymentMethod,
        status: orderStatus,
      );

      await _orderRepository.createOrderItems(
        orderId: orderId,
        items: orderItems,
      );

      if (!mounted) return;
      
      // Handle navigation based on payment method
      if (paymentMethod == 'Pay on counter') {
        // Navigate to payment process page
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentProcessPage(
              orderId: orderId,
              userName: userName,
              tableNumber: widget.tableNumber,
              totalPrice: widget.totalPrice,
            ),
          ),
        );
      } else {
        // Show success message for online payment
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order berhasil! Payment: $paymentMethod'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back to home
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

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
                  InkWell(
                    onTap: _isSaving ? null : () => _saveOrder('Pay on online'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _isSaving 
                            ? Colors.grey 
                            : const Color(0xFFA3806B),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isSaving
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          : Text(
                              'Pay on online',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pay on counter button
                  InkWell(
                    onTap: _isSaving ? null : () => _saveOrder('Pay on counter'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _isSaving 
                            ? Colors.grey 
                            : const Color(0xFFA3806B),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isSaving
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          : Text(
                              'Pay on counter',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
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

