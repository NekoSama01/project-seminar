import 'dart:io'; // ใช้สำหรับ File (รูปภาพ)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadPostPage extends StatefulWidget {
  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  File? _imageFile; // เก็บไฟล์รูปที่เลือก
  final _picker = ImagePicker();
  final _textController = TextEditingController();
  bool _isLoading = false;

  /// เลือกรูปจากแกลเลอรี่หรือกล้อง
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// อัปโหลดโพสต์ขึ้น Firebase
  Future<void> _uploadPost() async {
    if (_imageFile == null || _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกรูปและใส่ข้อความก่อนโพสต์')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ดึง user ปัจจุบันจาก Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("ยังไม่ได้ล็อกอิน");
      }

      // อัปโหลดรูปไปที่ Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // สร้าง document ใหม่ใน Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid, // ID ของผู้โพสต์
        'text': _textController.text.trim(),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โพสต์สำเร็จ!')),
      );

      _textController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโพสต์')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("สร้างโพสต์")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // แสดงรูปที่เลือก หรือปุ่มเลือกรูป
            _imageFile != null
                ? Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text('ยังไม่มีรูปที่เลือก')),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.photo),
                  label: Text('เลือกจากแกลเลอรี่'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                TextButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('ถ่ายรูป'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
            // กล่องข้อความสำหรับพิมพ์เนื้อหาโพสต์
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'เขียนแคปชั่น...',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            // ปุ่มโพสต์
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text('โพสต์'),
                    onPressed: _uploadPost,
                  ),
          ],
        ),
      ),
    );
  }
}
