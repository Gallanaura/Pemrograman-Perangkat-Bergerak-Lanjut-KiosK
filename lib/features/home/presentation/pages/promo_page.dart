import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.brandBrown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Promo & Discount',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            // Promo List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _PromoCard(
                    title: 'Special Discount',
                    discount: '30%',
                    description: 'Get up to 30% off on all drinks',
                    gradient: const LinearGradient(
                      colors: [Colors.black, Color(0xFF1F1A17)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.local_drink,
                  ),
                  const SizedBox(height: 16),
                  _PromoCard(
                    title: 'Buy 2 Get 1 Free',
                    discount: 'FREE',
                    description: 'Buy any 2 drinks and get 1 free',
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandBrown,
                        AppColors.brandBrown.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.card_giftcard,
                  ),
                  const SizedBox(height: 16),
                  _PromoCard(
                    title: 'Weekend Special',
                    discount: '25%',
                    description: 'Enjoy 25% discount every weekend',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.weekend,
                  ),
                  const SizedBox(height: 16),
                  _PromoCard(
                    title: 'Student Discount',
                    discount: '15%',
                    description: 'Show your student ID and get 15% off',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.school,
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

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.title,
    required this.discount,
    required this.description,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String discount;
  final String description;
  final Gradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          // Discount Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  discount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.brandBrown,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'OFF',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

