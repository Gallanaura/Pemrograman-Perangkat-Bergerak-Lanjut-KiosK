import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/core/services/image_storage_service.dart';
import 'package:kiosk/features/home/data/repositories/product_repository.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final ProductRepository _productRepository = ProductRepository();
  final ImageStorageService _imageStorageService = ImageStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final products = await _productRepository.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final ratingController = TextEditingController(text: '4.0');
    final imageUrlController = TextEditingController();
    String selectedCategory = 'all';
    File? selectedImageFile;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage(ImageSource source) async {
            try {
              final XFile? pickedFile = await _imagePicker.pickImage(source: source);
              if (pickedFile != null) {
                setState(() {
                  selectedImageFile = File(pickedFile.path);
                  imageUrlController.clear();
                });
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error picking image: $e')),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text('Add Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ratingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rating',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Image Upload Section - More Prominent
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brandBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brandBrown.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image, color: AppColors.brandBrown, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Upload Foto Produk',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library, size: 20),
                                label: const Text('Pilih dari Gallery'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.brandBrown,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt, size: 20),
                                label: const Text('Ambil Foto'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.brandBrown,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Image URL field (alternative)
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Atau Masukkan URL Gambar (Opsional)',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                      helperText: 'Jika tidak upload foto, bisa masukkan URL gambar',
                    ),
                    onChanged: (_) {
                      if (imageUrlController.text.isNotEmpty) {
                        setState(() {
                          selectedImageFile = null;
                        });
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  // Image Preview
                  if (selectedImageFile != null)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                selectedImageFile!.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )
                            : Image.file(
                                selectedImageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    )
                  else if (imageUrlController.text.isNotEmpty)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrlController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                      DropdownMenuItem(value: 'discount', child: Text('Discount')),
                      DropdownMenuItem(value: 'special_discount', child: Text('Special Discount')),
                      DropdownMenuItem(value: 'weekend_special', child: Text('Weekend Special')),
                      DropdownMenuItem(value: 'student_discount', child: Text('Student Discount')),
                      DropdownMenuItem(value: 'buy2get1', child: Text('Buy 2 Get 1 Free')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? 'all';
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty) {
                    String? finalImagePath;
                    
                    // Save uploaded image if exists
                    if (selectedImageFile != null && !kIsWeb) {
                      try {
                        finalImagePath = await _imageStorageService.saveProductImage(
                          selectedImageFile!,
                          nameController.text,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving image: $e')),
                          );
                        }
                        return;
                      }
                    } else if (imageUrlController.text.trim().isNotEmpty) {
                      finalImagePath = imageUrlController.text.trim();
                    }

                    await _productRepository.insertProduct(
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      rating: double.parse(ratingController.text),
                      imageUrl: finalImagePath,
                      category: selectedCategory,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadProducts();
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBrown,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditProductDialog(Map<String, dynamic> product) async {
    final nameController = TextEditingController(text: product['name'] as String);
    final priceController = TextEditingController(text: (product['price'] as int).toString());
    final ratingController = TextEditingController(text: (product['rating'] as num).toString());
    final existingImagePath = product['image_url'] as String? ?? '';
    final imageUrlController = TextEditingController(text: existingImagePath);
    String selectedCategory = product['category'] as String? ?? 'all';
    File? selectedImageFile;
    final bool isExistingImageLocal = existingImagePath.isNotEmpty && 
        _imageStorageService.isLocalPath(existingImagePath);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage(ImageSource source) async {
            try {
              final XFile? pickedFile = await _imagePicker.pickImage(source: source);
              if (pickedFile != null) {
                setState(() {
                  selectedImageFile = File(pickedFile.path);
                  imageUrlController.clear();
                });
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error picking image: $e')),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text('Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ratingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Rating',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Image Upload Section
                  const Text(
                    'Product Image',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Image URL field (alternative)
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Or Image URL (Optional)',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    onChanged: (_) {
                      if (imageUrlController.text.isNotEmpty) {
                        setState(() {
                          selectedImageFile = null;
                        });
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  // Image Preview
                  if (selectedImageFile != null)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                selectedImageFile!.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )
                            : Image.file(
                                selectedImageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    )
                  else if (imageUrlController.text.isNotEmpty)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isExistingImageLocal && !kIsWeb
                            ? Image.file(
                                File(imageUrlController.text),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              )
                            : Image.network(
                                imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                      DropdownMenuItem(value: 'discount', child: Text('Discount')),
                      DropdownMenuItem(value: 'special_discount', child: Text('Special Discount')),
                      DropdownMenuItem(value: 'weekend_special', child: Text('Weekend Special')),
                      DropdownMenuItem(value: 'student_discount', child: Text('Student Discount')),
                      DropdownMenuItem(value: 'buy2get1', child: Text('Buy 2 Get 1 Free')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? 'all';
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty) {
                    String? finalImagePath;
                    
                    // Save uploaded image if exists
                    if (selectedImageFile != null && !kIsWeb) {
                      try {
                        // Delete old image if it's a local file
                        if (isExistingImageLocal) {
                          await _imageStorageService.deleteProductImage(existingImagePath);
                        }
                        // Save new image
                        finalImagePath = await _imageStorageService.saveProductImage(
                          selectedImageFile!,
                          nameController.text,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving image: $e')),
                          );
                        }
                        return;
                      }
                    } else if (imageUrlController.text.trim().isNotEmpty) {
                      // If URL changed and old was local, delete old file
                      if (isExistingImageLocal && imageUrlController.text.trim() != existingImagePath) {
                        await _imageStorageService.deleteProductImage(existingImagePath);
                      }
                      finalImagePath = imageUrlController.text.trim();
                    } else if (isExistingImageLocal) {
                      // If image was removed, delete old file
                      await _imageStorageService.deleteProductImage(existingImagePath);
                    }

                    await _productRepository.updateProduct(
                      id: product['id'] as int,
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      rating: double.parse(ratingController.text),
                      imageUrl: finalImagePath,
                      category: selectedCategory,
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadProducts();
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBrown,
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Get product details to check for image file
      final product = await _productRepository.getProductById(id);
      if (product != null) {
        final imagePath = product['image_url'] as String?;
        // Delete image file if it's a local file
        if (imagePath != null && 
            imagePath.isNotEmpty && 
            _imageStorageService.isLocalPath(imagePath)) {
          await _imageStorageService.deleteProductImage(imagePath);
        }
      }
      await _productRepository.deleteProduct(id);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Add Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              FilledButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBrown,
                ),
              ),
            ],
          ),
        ),
        // Products List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? Center(
                      child: Text(
                        'No products yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.brandBrown.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_cafe_rounded,
                                color: AppColors.brandBrown,
                              ),
                            ),
                            title: Text(
                              product['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rp ${(product['price'] as int).toString().replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]}.',
                                      )}',
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandBrown.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Category: ${product['category'] ?? 'all'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.brandBrown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < (product['rating'] as num).toInt()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.brandBrown),
                                  onPressed: () => _showEditProductDialog(product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(
                                    product['id'] as int,
                                    product['name'] as String,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

