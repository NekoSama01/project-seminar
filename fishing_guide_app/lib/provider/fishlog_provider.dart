import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FishLogProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot>? _fishLogList;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _fishLogSubscription;

  // Getters
  List<DocumentSnapshot>? get fishLogList => _fishLogList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get fishLogCount => _fishLogList?.length ?? 0;
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize stream subscription
  void initializeFishLogStream() {
    final userId = currentUserId;

    // 🔍 เพิ่ม Debug
    print('🔍 Debug: Current User ID = $userId');
    print('🔍 Debug: Current User = ${_auth.currentUser?.email}');

    if (userId == null) {
      _error = 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบ';
      print('❌ Debug: No user found');
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    print('🔍 Debug: Starting stream for userId: $userId');

    _fishLogSubscription = _firestore
        .collection('fishlogs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            print('🔍 Debug: Received ${snapshot.docs.length} documents');

            // 🔍 Debug แต่ละ document
            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              print(
                '🔍 Debug Doc: ${doc.id} - userId: ${data['userId']} - user: ${data['username']}',
              );
            }

            _fishLogList = snapshot.docs;
            _setLoading(false);
            _clearError();
            notifyListeners();
          },
          onError: (error) {
            print('❌ Debug: Stream error: $error');
            _setError('เกิดข้อผิดพลาดในการโหลดข้อมูล: $error');
            _setLoading(false);
            notifyListeners();
          },
        );
  }

  // Fetch fish logs manually (for refresh)
  Future<void> fetchFishLogs() async {
    final userId = currentUserId;

    print('🔍 Debug: Manual fetch for userId: $userId');

    if (userId == null) {
      _setError('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบ');
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      notifyListeners();

      final QuerySnapshot snapshot =
          await _firestore
              .collection('fishlogs')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      print('🔍 Debug: Manual fetch got ${snapshot.docs.length} documents');

      _fishLogList = snapshot.docs;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      print('❌ Debug: Manual fetch error: $e');
      _setError('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

  // Delete fish log
  Future<bool> deleteFishLog(String documentId) async {
    try {
      // 🔍 ตรวจสอบว่า document นี้เป็นของ current user หรือไม่
      final doc = await _firestore.collection('fishlogs').doc(documentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['userId'] != currentUserId) {
          _setError('คุณไม่มีสิทธิ์ลบบันทึกนี้');
          notifyListeners();
          return false;
        }
      }

      await _firestore.collection('fishlogs').doc(documentId).delete();
      print('✅ Debug: Successfully deleted document: $documentId');
      return true;
    } catch (e) {
      print('❌ Debug: Delete error: $e');
      _setError('เกิดข้อผิดพลาดในการลบบันทึก: $e');
      notifyListeners();
      return false;
    }
  }

  // Add new fish log
  Future<bool> addFishLog({required String detail, String? imageURL}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล');
      notifyListeners();
      return false;
    }

    try {
      final fishLogData = {
        'imageURL': imageURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'detail': detail.trim(),
        'username': user.displayName ?? user.email ?? 'Unknown User',
        'userId': user.uid, // 🔍 ตรวจสobให้แน่ใจว่ามี userId
      };

      print('🔍 Debug: Adding fish log with data: $fishLogData');

      await _firestore.collection('fishlogs').add(fishLogData);
      print('✅ Debug: Successfully added fish log');
      return true;
    } catch (e) {
      print('❌ Debug: Add error: $e');
      _setError('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e');
      notifyListeners();
      return false;
    }
  }

  // Update fish log
  Future<bool> updateFishLog({
    required String documentId,
    required String detail,
    String? imageURL,
  }) async {
    try {
      // ตรวจสอบว่า document มีอยู่และเป็นของ user
      final doc = await _firestore.collection('fishlogs').doc(documentId).get();
      if (!doc.exists) {
        _setError('ไม่พบข้อมูลที่ต้องการแก้ไข');
        notifyListeners();
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != currentUserId) {
        _setError('คุณไม่มีสิทธิ์แก้ไขบันทึกนี้');
        notifyListeners();
        return false;
      }

      // อัพเดทข้อมูล
      final updateData = <String, dynamic>{
        'detail': detail.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageURL != null) {
        updateData['imageURL'] = imageURL;
      }

      await _firestore
          .collection('fishlogs')
          .doc(documentId)
          .update(updateData);

      // ⭐ สำคัญ: ไม่ต้อง notifyListeners() ที่นี่ เพราะ stream จะ update เอง
      print('✅ Debug: Successfully updated document: $documentId');
      return true;
    } catch (e) {
      print('❌ Debug: Update error: $e');
      _setError('เกิดข้อผิดพลาดในการแก้ไขข้อมูล: $e');
      notifyListeners();
      return false;
    }
  }

  // Get specific fish log
  Future<DocumentSnapshot?> getFishLog(String documentId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('fishlogs').doc(documentId).get();

      if (doc.exists) {
        // 🔍 ตรวจสอบว่าเป็นของ current user หรือไม่
        final data = doc.data() as Map<String, dynamic>;
        if (data['userId'] == currentUserId) {
          return doc;
        } else {
          _setError('คุณไม่มีสิทธิ์เข้าถึงบันทึกนี้');
          notifyListeners();
          return null;
        }
      }
      return null;
    } catch (e) {
      print('❌ Debug: Get fish log error: $e');
      _setError('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
      notifyListeners();
      return null;
    }
  }

  // Search fish logs (เฉพาะของตัวเอง)
  List<DocumentSnapshot> searchFishLogs(String query) {
    if (_fishLogList == null || query.isEmpty) {
      return _fishLogList ?? [];
    }

    return _fishLogList!.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final detail = data['detail']?.toString().toLowerCase() ?? '';
      final username = data['username']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return detail.contains(searchLower) || username.contains(searchLower);
    }).toList();
  }

  // 🆕 เพิ่ม method สำหรับตรวจสอบสถานะ Auth
  void checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('🔍 Debug: User signed out');
        clearData();
      } else {
        print('🔍 Debug: User signed in: ${user.email}');
        // รีเฟรชข้อมูลเมื่อมีการ login ใหม่
        initializeFishLogStream();
      }
    });
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }

  // Clear all data
  void clearData() {
    _fishLogList = null;
    _isLoading = false;
    _error = null;
    _fishLogSubscription?.cancel();
    notifyListeners();
  }

  // Format date time
  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';

    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }

  void forceRefresh() {
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    _fishLogSubscription?.cancel();
    super.dispose();
  }
}
