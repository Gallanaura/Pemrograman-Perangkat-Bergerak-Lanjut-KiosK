import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ö cöke',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Guest',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.person, color: AppColors.brandBrown),
        ),
      ],
    );
  }
}

