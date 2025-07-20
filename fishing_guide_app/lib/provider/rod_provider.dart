import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class RodProvider with ChangeNotifier {
  List<QueryDocumentSnapshot>? _rodList;
  bool _isLoading = false;
  String? _error;
  final Map<String, ImageProvider> _imageCache = {};
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  List<QueryDocumentSnapshot>? get rodList => _rodList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRods() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('rods')
          .get();

      _rodList = snapshot.docs;
      _error = null;
      
      // Pre-cache images in the background
      _precacheImages();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลคันเบ็ด: $e';
      _rodList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _precacheImages() async {
    if (_rodList == null) return;
    
    for (final doc in _rodList!) {
      final imageUrl = doc['image_url'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _getImageProvider(imageUrl);
      }
    }
  }

  Future<ImageProvider?> getRodImage(String documentId) async {
    if (_rodList == null) return null;
    
    final doc = _rodList!.firstWhere(
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
      debugPrint('Failed to load rod image: $e');
      throw Exception('Failed to load rod image: $e');
    }
  }

  // Clear cache when needed
  void clearImageCache() {
    _imageCache.clear();
    _cacheManager.emptyCache();
  }

  Future<void> precacheAllImages(BuildContext context) async {
    if (_rodList == null) return;
    
    for (final doc in _rodList!) {
      final imageUrl = doc['image_url'] as String?;
      if (imageUrl != null) {
        try {
          final provider = await _getImageProvider(imageUrl);
          if (provider != null) {
            precacheImage(provider, context);
          }
        } catch (e) {
          debugPrint('Precache failed for rod image $imageUrl: $e');
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

  // Function to get color based on rod type
  Color getRodTypeColor(String type) {
    switch (type) {
      case 'แบบดั้งเดิม':
        return Colors.brown.shade400;
      case 'แบบสมัยใหม่':
        return Colors.blue.shade400;
      case 'แบบมืออาชีพ':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  // Function to get icon based on rod type
  IconData getRodTypeIcon(String type) {
    switch (type) {
      case 'แบบดั้งเดิม':
        return Icons.history;
      case 'แบบสมัยใหม่':
        return Icons.auto_awesome;
      case 'แบบมืออาชีพ':
        return Icons.workspace_premium;
      default:
        return Icons.category;
    }
  }
}