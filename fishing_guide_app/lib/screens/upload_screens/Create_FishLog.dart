import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadFishLogPage extends StatefulWidget {
  @override
  State<UploadFishLogPage> createState() => _UploadFishLogPageState();
}

class _UploadFishLogPageState extends State<UploadFishLogPage> {
  File? _imageFile;
  final _picker = ImagePicker();
  final _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadFishLog() async {
    final firestore = FirebaseFirestore.instance;

    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาใส่รายละเอียดก่อนบันทึก')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("ยังไม่ได้ล็อกอิน");

      // ดึง username จาก users collection
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final username = userDoc['username'] ?? 'Unknown';

      String? imageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('fishlog_images')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // บันทึกข้อมูลไปที่ collection fishlogs
      await firestore.collection('fishlogs').add({
        'userId': user.uid,
        'username': username,
        'detail': _textController.text.trim(), // ใช้ detail แทน text
        'imageURL': imageUrl, // ตรงกับ rules
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('บันทึกสำเร็จ!')));

      _textController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เพิ่ม Fish Log")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'เขียนรายละเอียดการตกปลา...'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text('บันทึก'),
                    onPressed: _uploadFishLog,
                  ),
          ],
        ),
      ),
    );
  }
}
