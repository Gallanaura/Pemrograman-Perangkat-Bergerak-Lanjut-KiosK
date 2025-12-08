class Drink {
  final int? id;
  final String name;
  final int price;
  final String? imageUrl;
  final double rating;
  final String category;

  const Drink(
    this.name, {
    this.id,
    this.price = 0,
    this.imageUrl,
    this.rating = 4.0,
    this.category = 'all',
  });
}

