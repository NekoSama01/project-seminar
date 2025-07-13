import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaitProvider with ChangeNotifier {
  List<QueryDocumentSnapshot>? _baitList;
  bool _isLoading = false;
  String? _error;

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
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลเหยื่อ: $e';
      _baitList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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