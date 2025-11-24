import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/models/drink.dart';

class HorizontalDrinkList extends StatelessWidget {
  const HorizontalDrinkList({
    super.key,
    required this.drinks,
    required this.cardColor,
  });

  final List<Drink> drinks;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => DrinkCard(
          drink: drinks[index],
          backgroundColor: cardColor,
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: drinks.length,
      ),
    );
  }
}

class DrinkCard extends StatelessWidget {
  const DrinkCard({
    super.key,
    required this.drink,
    required this.backgroundColor,
  });

  final Drink drink;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.local_cafe_rounded, color: AppColors.brandBrown),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            drink.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

