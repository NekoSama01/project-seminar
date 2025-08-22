import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StepModel {
  final String id;
  final Map<String, dynamic> data;

  StepModel({
    required this.id,
    required this.data,
  });

  factory StepModel.fromFirestore(DocumentSnapshot doc) {
    return StepModel(
      id: doc.id,
      data: doc.data() as Map<String, dynamic>,
    );
  }
}

class StepsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<StepModel> _steps = [];
  bool _isLoading = false;
  String _error = '';

  List<StepModel> get steps => _steps;
  bool get isLoading => _isLoading;
  String get error => _error;

  StepsProvider() {
    _listenToSteps();
  }

  // ฟังการเปลี่ยนแปลงข้อมูลแบบ real-time
  void _listenToSteps() {
    _setLoading(true);
    
    _firestore
        .collection('step')
        .orderBy(FieldPath.documentId)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          _steps = snapshot.docs
              .map((doc) => StepModel.fromFirestore(doc))
              .toList();
          _error = '';
          _setLoading(false);
          print('Steps loaded: ${_steps.length} items'); // Debug log
        } catch (e) {
          _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${e.toString()}';
          _setLoading(false);
          print('Error loading steps: $e'); // Debug log
        }
      },
      onError: (error) {
        _error = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${error.toString()}';
        _setLoading(false);
        print('Firestore connection error: $error'); // Debug log
      },
    );
  }

  // เพิ่มเมธอด fetchSteps สำหรับการดึงข้อมูลครั้งแรก
  Future<void> fetchSteps() async {
    _setLoading(true);
    _error = '';
    
    try {
      final snapshot = await _firestore
          .collection('step')
          .orderBy(FieldPath.documentId)
          .get();
      
      _steps = snapshot.docs
          .map((doc) => StepModel.fromFirestore(doc))
          .toList();
      
      print('Fetched steps: ${_steps.length} items'); // Debug log
      
      if (_steps.isEmpty) {
        print('No documents found in steps collection'); // Debug log
      }
      
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลด: ${e.toString()}';
      print('Error fetching steps: $e'); // Debug log
    } finally {
      _setLoading(false);
    }
  }

  // ดึงข้อมูล step ตาม ID
  StepModel? getStepById(String id) {
    try {
      return _steps.firstWhere((step) => step.id == id);
    } catch (e) {
      return null;
    }
  }

  // ดึงข้อมูล field จาก step ที่เฉพาะเจาะจง
  String getFieldValue(String stepId, String fieldName) {
    final step = getStepById(stepId);
    if (step != null && step.data.containsKey(fieldName)) {
      return step.data[fieldName].toString();
    }
    return 'ไม่พบข้อมูล';
  }

  // รีเฟรชข้อมูล
  Future<void> refreshSteps() async {
    _setLoading(true);
    _error = '';
    
    try {
      final snapshot = await _firestore
          .collection('step')
          .orderBy(FieldPath.documentId)
          .get();
      
      _steps = snapshot.docs
          .map((doc) => StepModel.fromFirestore(doc))
          .toList();
          
      print('Refreshed steps: ${_steps.length} items'); // Debug log
      
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการรีเฟรช: ${e.toString()}';
      print('Error refreshing steps: $e'); // Debug log
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper methods สำหรับ UI
  Color getHeaderColor(String docId) {
    switch (docId) {
      case '001':
        return const Color(0xFFFF9800); // Green
      case '002':
        return const Color(0xFF4CAF50); // Orange
      case '003':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }

  String getDocumentTitle(String docId) {
    switch (docId) {
      case '001':
        return 'คันเบ็ดสปินนิ่ง (Spinning Rod)';
      case '002':
        return 'คันเบ็ดไม้ไผ่ (Bamboo Rod)';
      case '003':
        return 'คันเบ็ดคาสติ้ง (Casting Rod)';
      default:
        return 'ข้อมูลการตกปลา';
    }
  }

  String getFieldDisplayName(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'attaching the bait':
        return '🎣 การติดเหยื่อ';
      case 'attaching the bait2':
        return '🎣 การติดเหยื่อ (แบบที่ 2)';
      case 'casting(spinning)':
        return '🎯 การโยนเบ็ด (สปินนิ่ง)';
      case 'casting':
        return '🎯 การโยนเบ็ด';
      case 'molding bait':
        return '🍞 การปั้นเหยื่อ';
      case 'molding bait2':
        return '🍞 การปั้นเหยื่อ (แบบที่ 2)';
      case 'hooking bait':
        return '🪝 การเกี่ยวเหยื่อ';
      case 'baitcasting rod':
        return '🎣 คันเบ็ดแบบ Baitcasting';
      default:
        return fieldName;
    }
  }

  // สถิติข้อมูล
  int get totalSteps => _steps.length;
  
  bool get hasData => _steps.isNotEmpty;
  
  Map<String, int> get stepStats {
    final stats = <String, int>{};
    for (final step in _steps) {
      final title = getDocumentTitle(step.id);
      stats[title] = step.data.length;
    }
    return stats;
  }

  // เพิ่มฟังก์ชันสำหรับ debug
  void debugInfo() {
    print('=== StepsProvider Debug Info ===');
    print('Total steps: ${_steps.length}');
    print('Is loading: $_isLoading');
    print('Error: $_error');
    print('Has data: $hasData');
    
    for (int i = 0; i < _steps.length; i++) {
      print('Step $i: ID=${_steps[i].id}, Fields=${_steps[i].data.keys.toList()}');
    }
    print('================================');
  }
}