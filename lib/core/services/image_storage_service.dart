import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  /// Get the directory where product images should be stored
  Future<Directory> _getProductImagesDirectory() async {
    if (kIsWeb) {
      // Web doesn't support file system access like mobile/desktop
      throw UnsupportedError('File storage not supported on web. Use image URLs instead.');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'product_images'));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }

  /// Save an image file and return its path
  Future<String> saveProductImage(File imageFile, String productName) async {
    if (kIsWeb) {
      throw UnsupportedError('File storage not supported on web. Use image URLs instead.');
    }

    final imagesDir = await _getProductImagesDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedProductName = productName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final fileName = '${sanitizedProductName}_$timestamp${path.extension(imageFile.path)}';
    final savedFile = await imageFile.copy(path.join(imagesDir.path, fileName));
    
    return savedFile.path;
  }

  /// Delete an image file by its path
  Future<bool> deleteProductImage(String imagePath) async {
    if (kIsWeb) {
      return false;
    }

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Check if an image path is a local file path (not a URL)
  bool isLocalPath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    // Check if it's a URL (starts with http:// or https://)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return false;
    }
    // Otherwise, assume it's a local file path
    return true;
  }
}

