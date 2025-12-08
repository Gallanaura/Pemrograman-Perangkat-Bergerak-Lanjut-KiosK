import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/models/drink.dart';
import 'package:kiosk/features/home/data/repositories/product_repository.dart';
import 'package:kiosk/features/home/presentation/pages/show_more_page.dart';
import 'package:kiosk/features/home/presentation/widgets/drink_list.dart';
import 'package:kiosk/features/home/presentation/widgets/header.dart';
import 'package:kiosk/features/home/presentation/widgets/promo_card.dart';
import 'package:kiosk/features/home/presentation/widgets/search_field.dart';
import 'package:kiosk/features/home/presentation/widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductRepository _productRepository = ProductRepository();
  List<Drink> allDrinks = [];
  List<Drink> recommendedDrinks = [];
  List<Drink> categoryDrinks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // Load all products
    final allProducts = await _productRepository.getAllProducts();
    allDrinks = _productRepository.mapToDrinks(allProducts);
    
    // Load recommended products
    final recommendedProducts = await _productRepository.getProductsByCategory('recommended');
    recommendedDrinks = _productRepository.mapToDrinks(recommendedProducts);
    
    // Load category products (all except recommended)
    final categoryProducts = await _productRepository.getProductsByCategory('all');
    categoryDrinks = _productRepository.mapToDrinks(categoryProducts);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                drinks: categoryDrinks.isNotEmpty ? categoryDrinks : allDrinks,
                cardColor: AppColors.brandBrown.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recommended',
                onNext: () {},
                onPrevious: () {},
              ),
              const SizedBox(height: 16),
              HorizontalDrinkList(
                drinks: recommendedDrinks.isNotEmpty ? recommendedDrinks : allDrinks,
                cardColor: AppColors.brandBrown.withValues(alpha: 0.2),
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
                        builder: (context) => ShowMorePage(),
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

