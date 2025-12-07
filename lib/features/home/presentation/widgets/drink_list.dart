import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/models/drink.dart';

class HorizontalDrinkList extends StatelessWidget {
  const HorizontalDrinkList({
    super.key,
    required this.drinks,
    required this.cardColor,
    this.onAddToCart,
    this.showPrice = false,
    this.showAddButton = false,
  });

  final List<Drink> drinks;
  final Color cardColor;
  final Function(Drink)? onAddToCart;
  final bool showPrice;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => DrinkCard(
          drink: drinks[index],
          backgroundColor: cardColor,
          onAddToCart: onAddToCart,
          showPrice: showPrice,
          showAddButton: showAddButton,
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
    this.onAddToCart,
    this.showPrice = false,
    this.showAddButton = false,
  });

  final Drink drink;
  final Color backgroundColor;
  final Function(Drink)? onAddToCart;
  final bool showPrice;
  final bool showAddButton;

  Color _getDrinkColor() {
    switch (drink.name) {
      case 'Dark Korawa':
        return const Color(0xFF6B4423); // Dark brown
      case 'Merseyside':
        return const Color(0xFFE91E63); // Pink/reddish
      case 'Taro':
        return const Color(0xFF9E9E9E); // Light purple/grey
      default:
        return const Color(0xFF8D6E63); // Default brown
    }
  }

  @override
  Widget build(BuildContext context) {
    final drinkColor = _getDrinkColor();
    
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drink Image Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Drink liquid
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 24),
                      decoration: BoxDecoration(
                        color: drinkColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // White lid
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Drink Name
          Text(
            drink.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (showPrice) ...[
            const SizedBox(height: 4),
            Text(
              'Rp${drink.price.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  )}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
          if (showAddButton && onAddToCart != null) ...[
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: () => onAddToCart!(drink),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GridDrinkList extends StatelessWidget {
  const GridDrinkList({
    super.key,
    required this.drinks,
    required this.cardColor,
    this.onAddToCart,
  });

  final List<Drink> drinks;
  final Color cardColor;
  final Function(Drink)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: drinks.length,
      itemBuilder: (context, index) => DrinkCard(
        drink: drinks[index],
        backgroundColor: cardColor,
        onAddToCart: onAddToCart,
        showPrice: true,
        showAddButton: true,
      ),
    );
  }
}

