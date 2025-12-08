import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/data/models/drink.dart';
import 'package:kiosk/features/home/data/models/cart_item.dart';
import 'package:kiosk/features/home/data/repositories/product_repository.dart';
import 'package:kiosk/features/home/presentation/pages/payment_page.dart';
import 'package:kiosk/features/home/presentation/widgets/drink_list.dart';
import 'package:kiosk/features/home/presentation/widgets/section_header.dart';

class ShowMorePage extends StatefulWidget {
  const ShowMorePage({super.key});

  @override
  State<ShowMorePage> createState() => _ShowMorePageState();
}

class _ShowMorePageState extends State<ShowMorePage> {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Drink> allDrinks = [];
  List<Drink> recommendedDrinks = [];
  List<Drink> filteredDrinks = [];
  List<Drink> filteredRecommendedDrinks = [];
  List<CartItem> cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterDrinks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    // Load all products
    final allProducts = await _productRepository.getAllProducts();
    allDrinks = _productRepository.mapToDrinks(allProducts);
    
    // Load recommended products separately
    final recommendedProducts = await _productRepository.getProductsByCategory('recommended');
    recommendedDrinks = _productRepository.mapToDrinks(recommendedProducts);
    
    setState(() {
      filteredDrinks = allDrinks;
      filteredRecommendedDrinks = recommendedDrinks;
      _isLoading = false;
    });
  }

  void _filterDrinks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredDrinks = allDrinks;
        filteredRecommendedDrinks = recommendedDrinks;
      } else {
        filteredDrinks = allDrinks
            .where((drink) => drink.name.toLowerCase().contains(query))
            .toList();
        filteredRecommendedDrinks = recommendedDrinks
            .where((drink) => drink.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _addToCart(Drink drink) {
    setState(() {
      final existingIndex = cartItems.indexWhere(
        (item) => item.drink.id == drink.id,
      );
      if (existingIndex >= 0) {
        cartItems[existingIndex] = cartItems[existingIndex].copyWith(
          quantity: cartItems[existingIndex].quantity + 1,
        );
      } else {
        cartItems.add(CartItem(drink: drink, quantity: 1));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drink.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
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

  Color _getDrinkColor(String drinkName) {
    switch (drinkName) {
      case 'Dark Korawa':
        return const Color(0xFF6B4423);
      case 'Merseyside':
        return const Color(0xFFE91E63);
      case 'Taro':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF8D6E63);
    }
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Products'),
          backgroundColor: AppColors.brandBrown,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        backgroundColor: AppColors.brandBrown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Recommended Section
                  if (filteredRecommendedDrinks.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Recommended',
                      onNext: () {},
                      onPrevious: () {},
                    ),
                    const SizedBox(height: 16),
                    HorizontalDrinkList(
                      drinks: filteredRecommendedDrinks,
                      cardColor: AppColors.brandBrown.withValues(alpha: 0.2),
                      onAddToCart: _addToCart,
                      showPrice: true,
                      showAddButton: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // All Products Section
                  SectionHeader(
                    title: 'All Products',
                    onNext: () {},
                    onPrevious: () {},
                  ),
                  const SizedBox(height: 16),
                  GridDrinkList(
                    drinks: filteredDrinks,
                    cardColor: AppColors.brandBrown.withValues(alpha: 0.2),
                    onAddToCart: _addToCart,
                  ),
                  const SizedBox(height: 100),
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
    );
  }
}

// Cart Summary Bar - Same as promo_detail_page
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
            color: Colors.black.withValues(alpha: 0.1),
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

// Cart Modal - Same as promo_detail_page
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

  void _navigateToPayment() {
    Navigator.pop(context); // Close cart modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartItems: widget.cartItems,
          totalPrice: widget.totalPrice,
          tableNumber: _tableNumberController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      ),
    );
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
              Text(
                'Your Order details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: widget.cartItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == widget.cartItems.length) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                        onPressed: _navigateToPayment,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Continue to Payment'),
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

// Cart Item Card - Same as promo_detail_page
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Drink Image/Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: getDrinkColor(cartItem.drink.name).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: cartItem.drink.imageUrl != null && cartItem.drink.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      cartItem.drink.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.local_cafe,
                        color: getDrinkColor(cartItem.drink.name),
                      ),
                    ),
                  )
                : Icon(
                    Icons.local_cafe,
                    color: getDrinkColor(cartItem.drink.name),
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
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < cartItem.drink.rating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${cartItem.drink.price.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.brandBrown,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (cartItem.quantity > 1)
                  Text(
                    'Subtotal: Rp ${cartItem.totalPrice.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
              ],
            ),
          ),
          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: onDecrease,
                  color: AppColors.brandBrown,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${cartItem.quantity}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onIncrease,
                  color: AppColors.brandBrown,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
