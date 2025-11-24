import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search a food items',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.brandBrown,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ),
    );
  }
}

