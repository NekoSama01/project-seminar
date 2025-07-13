import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RodProvider with ChangeNotifier {
  List<QueryDocumentSnapshot>? _rodList;
  bool _isLoading = false;
  String? _error;

  List<QueryDocumentSnapshot>? get rodList => _rodList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Function to get color based on rod type
  Color getRodTypeColor(String type) {
    switch (type) {
      case 'แบบดั้งเดิม':
        return Colors.brown.shade400; // Traditional color
      case 'แบบสมัยใหม่':
        return Colors.blue.shade400; // Modern color
      case 'แบบมืออาชีพ':
        return Colors.red.shade400; // Professional color
      default:
        return Colors.grey.shade400;
    }
  }

  // Function to get icon based on rod type
  IconData getRodTypeIcon(String type) {
    switch (type) {
      case 'แบบดั้งเดิม':
        return Icons.history; // Traditional icon
      case 'แบบสมัยใหม่':
        return Icons.auto_awesome; // Modern icon
      case 'แบบมืออาชีพ':
        return Icons.workspace_premium; // Professional icon
      default:
        return Icons.category;
    }
  }

  Future<void> fetchRods() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('rods')
          .get();

      _rodList = snapshot.docs;
      _error = null;
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลคันเบ็ด: $e';
      _rodList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}