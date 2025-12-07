import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/models/drink.dart';
import 'package:kiosk/features/home/presentation/pages/show_more_page.dart';
import 'package:kiosk/features/home/presentation/widgets/drink_list.dart';
import 'package:kiosk/features/home/presentation/widgets/header.dart';
import 'package:kiosk/features/home/presentation/widgets/promo_card.dart';
import 'package:kiosk/features/home/presentation/widgets/search_field.dart';
import 'package:kiosk/features/home/presentation/widgets/section_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final List<Drink> drinks = [
    const Drink('Dark Korawa', price: 20000),
    const Drink('Merseyside', price: 15000),
    const Drink('Savaya', price: 15000),
    const Drink('Taro', price: 15000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 24),
              const HomeSearchField(),
              const SizedBox(height: 24),
              const PromoCard(),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Categories',
                onNext: () {},
                onPrevious: () {},
              ),
              const SizedBox(height: 16),
              HorizontalDrinkList(
                drinks: drinks,
                cardColor: AppColors.brandBrown.withOpacity(0.2),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recommended',
                onNext: () {},
                onPrevious: () {},
              ),
              const SizedBox(height: 16),
              HorizontalDrinkList(
                drinks: drinks,
                cardColor: AppColors.brandBrown.withOpacity(0.2),
              ),
              const SizedBox(height: 32),
              Center(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShowMorePage(),
                      ),
                    );
                  },
                  child: const Text('Show more'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

