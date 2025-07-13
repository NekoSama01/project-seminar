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
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ฟังก์ชันช่วยเหลือสำหรับการแสดงข้อมูล
  String getRodNameTH(QueryDocumentSnapshot rod) {
    return rod['nameTH'] ?? 'ไม่มีชื่อ';
  }

  String getRodImageUrl(QueryDocumentSnapshot rod) {
    return rod['imageUrl'] ?? '';
  }

  String getRodType(QueryDocumentSnapshot rod) {
    return rod['type'] ?? 'ไม่ระบุประเภท';
  }

  String getRodLength(QueryDocumentSnapshot rod) {
    return rod['length'] ?? 'ไม่ระบุความยาว';
  }

  String getRodMaterial(QueryDocumentSnapshot rod) {
    return rod['material'] ?? 'ไม่ระบุวัสดุ';
  }

  String getRodAction(QueryDocumentSnapshot rod) {
    return rod['action'] ?? 'ไม่ระบุการทำงาน';
  }
}