import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FishProvider with ChangeNotifier {
  List<QueryDocumentSnapshot>? _fishList;
  bool _isLoading = false;
  String? _error;
  final Map<String, ImageProvider> _imageCache = {};
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  List<QueryDocumentSnapshot>? get fishList => _fishList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFishes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('fishes')
          .get();

      _fishList = snapshot.docs;
      _error = null;
      
      // Pre-cache images in the background
      _precacheImages();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
      _fishList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _precacheImages() async {
    if (_fishList == null) return;
    
    for (final doc in _fishList!) {
      final imageUrl = doc['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _getImageProvider(imageUrl);
      }
    }
  }

  Future<ImageProvider?> getFishImage(String documentId) async {
    if (_fishList == null) return null;
    
    final doc = _fishList!.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => throw Exception('Document not found'),
    );
    
    final imageUrl = doc['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    return await _getImageProvider(imageUrl);
  }

  Future<ImageProvider> _getImageProvider(String imageUrl) async {
  // แปลง URL ก่อนใช้งาน
  final convertedUrl = _convertGsToHttpsUrl(imageUrl);
  
  // Check cache first
  if (_imageCache.containsKey(convertedUrl)) {
    return _imageCache[convertedUrl]!;
  }
  
  // Download and cache the image
  try {
    final file = await _cacheManager.getSingleFile(convertedUrl);
    final imageProvider = FileImage(file);
    
    // Store in memory cache
    _imageCache[convertedUrl] = imageProvider;
    
    return imageProvider;
  } catch (e) {
    debugPrint('Failed to load image: $e');
    throw Exception('Failed to load image: $e');
  }
}
  // Clear cache when needed
  void clearImageCache() {
    _imageCache.clear();
    _cacheManager.emptyCache();
  }

  Future<void> precacheAllImages(BuildContext context) async {
    if (_fishList == null) return;
    
    for (final doc in _fishList!) {
      final imageUrl = doc['image_url'] as String?;
      if (imageUrl != null) {
        try {
          final provider = await _getImageProvider(imageUrl);
          if (provider != null) {
            precacheImage(provider, context); // ⚠️ ใช้ Flutter's precacheImage
          }
        } catch (e) {
          debugPrint('Precache failed for $imageUrl: $e');
        }
      }
    }
  }
  String _convertGsToHttpsUrl(String gsUrl) {
    // แปลงจาก gs://bucket-name/path/to/image
    // เป็น https://firebasestorage.googleapis.com/v0/b/bucket-name/o/path%2Fto%2Fimage?alt=media
    if (!gsUrl.startsWith('gs://')) return gsUrl;
    
    final uri = gsUrl.substring(5); // ตัด 'gs://' ออก
    final parts = uri.split('/');
    final bucket = parts[0];
    final path = parts.sublist(1).join('/');
    
    return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(path)}?alt=media';
  }
}