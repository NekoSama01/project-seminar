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
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ฟังก์ชันช่วยเหลือสำหรับการแสดงข้อมูล
  String getBaitNameTH(QueryDocumentSnapshot bait) {
    return bait['nameTH'] ?? 'ไม่มีชื่อ';
  }

  String getBaitImageUrl(QueryDocumentSnapshot bait) {
    return bait['imageUrl'] ?? '';
  }

  String getBaitType(QueryDocumentSnapshot bait) {
    return bait['type'] ?? 'ไม่ระบุประเภท';
  }

  String getBaitColor(QueryDocumentSnapshot bait) {
    return bait['color'] ?? 'ไม่ระบุสี';
  }

  String getBaitSize(QueryDocumentSnapshot bait) {
    return bait['size'] ?? 'ไม่ระบุขนาด';
  }

  String getBaitBestFor(QueryDocumentSnapshot bait) {
    return bait['bestFor'] ?? 'ใช้ได้กับปลาทุกชนิด';
  }
}