import 'package:kiosk/features/home/data/models/drink.dart';

class CartItem {
  final Drink drink;
  int quantity;

  CartItem({
    required this.drink,
    this.quantity = 1,
  });

  int get totalPrice => drink.price * quantity;

  CartItem copyWith({
    Drink? drink,
    int? quantity,
  }) {
    return CartItem(
      drink: drink ?? this.drink,
      quantity: quantity ?? this.quantity,
    );
  }
}

