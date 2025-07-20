import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BaitProvider with ChangeNotifier {
  List<QueryDocumentSnapshot>? _baitList;
  bool _isLoading = false;
  String? _error;
  final Map<String, ImageProvider> _imageCache = {};
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  List<QueryDocumentSnapshot>? get baitList => _baitList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBaits() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('baits')
          .get();

      _baitList = snapshot.docs;
      _error = null;
      
      // Pre-cache images in the background
      _precacheImages();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลเหยื่อ: $e';
      _baitList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _precacheImages() async {
    if (_baitList == null) return;
    
    for (final doc in _baitList!) {
      final imageUrl = doc['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _getImageProvider(imageUrl);
      }
    }
  }

  Future<ImageProvider?> getBaitImage(String documentId) async {
    if (_baitList == null) return null;
    
    final doc = _baitList!.firstWhere(
      (doc) => doc.id == documentId,
      orElse: () => throw Exception('Document not found'),
    );
    
    final imageUrl = doc['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    return await _getImageProvider(imageUrl);
  }

  Future<ImageProvider> _getImageProvider(String imageUrl) async {
    // Convert URL if it's a GS URL
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
      debugPrint('Failed to load bait image: $e');
      throw Exception('Failed to load bait image: $e');
    }
  }

  // Clear cache when needed
  void clearImageCache() {
    _imageCache.clear();
    _cacheManager.emptyCache();
  }

  Future<void> precacheAllImages(BuildContext context) async {
    if (_baitList == null) return;
    
    for (final doc in _baitList!) {
      final imageUrl = doc['image_url'] as String?;
      if (imageUrl != null) {
        try {
          final provider = await _getImageProvider(imageUrl);
          if (provider != null) {
            precacheImage(provider, context);
          }
        } catch (e) {
          debugPrint('Precache failed for bait image $imageUrl: $e');
        }
      }
    }
  }

  String _convertGsToHttpsUrl(String gsUrl) {
    if (!gsUrl.startsWith('gs://')) return gsUrl;
    
    final uri = gsUrl.substring(5); // Remove 'gs://'
    final parts = uri.split('/');
    final bucket = parts[0];
    final path = parts.sublist(1).join('/');
    
    return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(path)}?alt=media';
  }

  // ฟังก์ชันช่วยเลือกสีตามประเภทเหยื่อ
  Color getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'พลาสติก':
        return Colors.blue.shade100;
      case 'ธรรมชาติ':
        return Colors.green.shade100;
      case 'แป้ง':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  // ฟังก์ชันช่วยเลือกสีข้อความตามประเภทเหยื่อ
  Color getTypeTextColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'พลาสติก':
        return Colors.blue.shade800;
      case 'ธรรมชาติ':
        return Colors.green.shade800;
      case 'แป้ง':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}