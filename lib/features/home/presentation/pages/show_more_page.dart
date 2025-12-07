import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/models/drink.dart';
import 'package:kiosk/features/home/data/models/cart_item.dart';
import 'package:kiosk/features/home/presentation/pages/payment_page.dart';
import 'package:kiosk/features/home/presentation/widgets/drink_list.dart';
import 'package:kiosk/features/home/presentation/widgets/section_header.dart';

class ShowMorePage extends StatefulWidget {
  const ShowMorePage({super.key});

  @override
  State<ShowMorePage> createState() => _ShowMorePageState();
}

class _ShowMorePageState extends State<ShowMorePage> {
  final List<Drink> allDrinks = [
    const Drink('Dark Korawa', price: 20000, rating: 4.5),
    const Drink('Merseyside', price: 15000, rating: 4.0),
    const Drink('Savaya', price: 15000, rating: 4.2),
    const Drink('Taro', price: 15000, rating: 4.3),
    const Drink('Dark Korawa', price: 20000, rating: 4.5),
    const Drink('Merseyside', price: 15000, rating: 4.0),
    const Drink('Taro', price: 15000, rating: 4.3),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Drink> filteredDrinks = [];
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    filteredDrinks = allDrinks;
    // Initialize with Merseyside in cart
    cartItems = [
      CartItem(
        drink: const Drink('Merseyside', price: 15000, rating: 4.0),
        quantity: 1,
      ),
    ];
    _searchController.addListener(_filterDrinks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDrinks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredDrinks = allDrinks;
      } else {
        filteredDrinks = allDrinks
            .where((drink) => drink.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Color _getDrinkColor(String drinkName) {
    switch (drinkName) {
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

  void _addToCart(Drink drink) {
    setState(() {
      final existingIndex = cartItems.indexWhere(
        (item) => item.drink.name == drink.name,
      );
      if (existingIndex != -1) {
        cartItems[existingIndex] = cartItems[existingIndex].copyWith(
          quantity: cartItems[existingIndex].quantity + 1,
        );
      } else {
        cartItems.add(CartItem(drink: drink, quantity: 1));
      }
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index] = cartItems[index].copyWith(
          quantity: cartItems[index].quantity - 1,
        );
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    });
  }

  int get _totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartModal(
        cartItems: cartItems,
        totalPrice: _totalPrice,
        onDecrease: _decreaseQuantity,
        onIncrease: _increaseQuantity,
        getDrinkColor: _getDrinkColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'burger',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: AppColors.pageBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.brandBrown,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Recommended Section
                    SectionHeader(
                      title: 'Recommended',
                      onNext: () {},
                      onPrevious: () {},
                    ),
                    const SizedBox(height: 16),
                    HorizontalDrinkList(
                      drinks: filteredDrinks,
                      cardColor: AppColors.brandBrown.withOpacity(0.2),
                      onAddToCart: _addToCart,
                      showPrice: true,
                      showAddButton: true,
                    ),
                    const SizedBox(height: 24),
                    // Categories Section
                    SectionHeader(
                      title: 'Categories',
                      onNext: () {},
                      onPrevious: () {},
                    ),
                    const SizedBox(height: 16),
                    GridDrinkList(
                      drinks: filteredDrinks,
                      cardColor: AppColors.brandBrown.withOpacity(0.2),
                      onAddToCart: _addToCart,
                    ),
                    const SizedBox(height: 100), // Space for bottom cart bar
                  ],
                ),
              ),
            ),
            // Bottom Cart Summary Bar
            if (cartItems.isNotEmpty)
              _CartSummaryBar(
                itemCount: cartItems.length,
                totalPrice: _totalPrice,
                onContinue: _showCartModal,
              ),
          ],
        ),
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  const _CartSummaryBar({
    required this.itemCount,
    required this.totalPrice,
    required this.onContinue,
  });

  final int itemCount;
  final int totalPrice;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Badge(
              label: Text('$itemCount'),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.brandBrown,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$itemCount item${itemCount > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Rp ${totalPrice.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Continue Button
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('continue'),
          ),
        ],
      ),
    );
  }
}

class _CartModal extends StatefulWidget {
  const _CartModal({
    required this.cartItems,
    required this.totalPrice,
    required this.onDecrease,
    required this.onIncrease,
    required this.getDrinkColor,
  });

  final List<CartItem> cartItems;
  final int totalPrice;
  final Function(int) onDecrease;
  final Function(int) onIncrease;
  final Color Function(String) getDrinkColor;

  @override
  State<_CartModal> createState() => _CartModalState();
}

class _CartModalState extends State<_CartModal> {
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _tableNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // Close Button
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange[200]!,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.orange),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Text(
                'Your Order details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: widget.cartItems.length + 1, // +1 for input fields
                  itemBuilder: (context, index) {
                    if (index == widget.cartItems.length) {
                      // Input fields section
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Table Number Field
                          Text(
                            'Nomor Meja',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tableNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan nomor meja',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: AppColors.pageBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: const Icon(
                                Icons.table_restaurant,
                                color: AppColors.brandBrown,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Notes Field
                          Text(
                            'Catatan / Pesan',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan catatan atau pesan khusus...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: AppColors.pageBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 40),
                                child: Icon(
                                  Icons.note_outlined,
                                  color: AppColors.brandBrown,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    final item = widget.cartItems[index];
                    return _CartItemCard(
                      cartItem: item,
                      onDecrease: () => widget.onDecrease(index),
                      onIncrease: () => widget.onIncrease(index),
                      getDrinkColor: widget.getDrinkColor,
                    );
                  },
                ),
              ),
              // Total and Continue Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Rp ${widget.totalPrice.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]}.',
                              )}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          // You can access the values here:
                          // _tableNumberController.text
                          // _notesController.text
                          Navigator.pop(context); // Close cart modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentPage(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('continue to pay'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.cartItem,
    required this.onDecrease,
    required this.onIncrease,
    required this.getDrinkColor,
  });

  final CartItem cartItem;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final Color Function(String) getDrinkColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drink Image Card
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandBrown.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: getDrinkColor(cartItem.drink.name),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Drink Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.drink.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                // Rating Stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < cartItem.drink.rating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber[600],
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Price per item
                Text(
                  'Rp ${cartItem.drink.price.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                // Subtotal (if quantity > 1)
                if (cartItem.quantity > 1)
                  Text(
                    'Subtotal: Rp ${cartItem.totalPrice.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.brandBrown,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
          ),
          // Quantity Controls
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.remove, color: AppColors.brandBrown, size: 18),
                  onPressed: onDecrease,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${cartItem.quantity}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.orange[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  onPressed: onIncrease,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

