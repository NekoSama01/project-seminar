import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FishProvider with ChangeNotifier {
  List<QueryDocumentSnapshot>? _fishList;
  bool _isLoading = false;
  String? _error;

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
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
      _fishList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}