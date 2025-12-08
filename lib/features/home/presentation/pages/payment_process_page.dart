import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/presentation/pages/home_page.dart';

class PaymentProcessPage extends StatefulWidget {
  final int orderId;
  final String userName;
  final String tableNumber;
  final int totalPrice;

  const PaymentProcessPage({
    super.key,
    required this.orderId,
    required this.userName,
    required this.tableNumber,
    required this.totalPrice,
  });

  @override
  State<PaymentProcessPage> createState() => _PaymentProcessPageState();
}

class _PaymentProcessPageState extends State<PaymentProcessPage> {
  Timer? _timer;
  int _countdown = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown <= 0) {
          _timer?.cancel();
          _navigateToHome();
        }
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.brandBrown.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions,
                  size: 60,
                  color: AppColors.brandBrown,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Menunggu Konfirmasi',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBrown,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.brandBrown.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.brandBrown.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Nama',
                      value: widget.userName,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.table_restaurant,
                      label: 'Nomor Meja',
                      value: widget.tableNumber.isEmpty ? 'N/A' : widget.tableNumber,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.receipt,
                      label: 'Order ID',
                      value: '#${widget.orderId}',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.payments,
                      label: 'Total',
                      value: 'Rp ${widget.totalPrice.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                          )}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Order Anda sedang menunggu konfirmasi dari admin.',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan sebutkan nama dan nomor meja Anda kepada admin untuk proses pembayaran.',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Countdown
              Text(
                'Halaman ini akan otomatis kembali ke beranda dalam $_countdown detik',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // OK Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _timer?.cancel();
                    _navigateToHome();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.brandBrown,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.brandBrown,
            ),
          ),
        ),
      ],
    );
  }
}

