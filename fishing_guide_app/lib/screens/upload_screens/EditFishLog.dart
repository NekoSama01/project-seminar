import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishing_guide_app/provider/fishlog_provider.dart';

class EditFishLogScreen extends StatefulWidget {
  final String? documentId;

  const EditFishLogScreen({Key? key, this.documentId}) : super(key: key);

  @override
  _EditFishLogScreenState createState() => _EditFishLogScreenState();
}

class _EditFishLogScreenState extends State<EditFishLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailController = TextEditingController();
  String? _imageUrl;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  DocumentSnapshot? _currentFishLog;

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      _loadFishLogData();
    }
  }

  Future<void> _loadFishLogData() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<FishLogProvider>(context, listen: false);
      final fishLog = await provider.getFishLog(widget.documentId!);

      if (fishLog != null) {
        setState(() {
          _currentFishLog = fishLog;
          final data = fishLog.data() as Map<String, dynamic>;
          _detailController.text = data['detail'] ?? '';
          _imageUrl = data['imageURL']; // เพิ่มการโหลด imageURL
        });
      } else {
        _showErrorDialog('ไม่พบข้อมูลที่ต้องการแก้ไข');
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateFishLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // อัปโหลดรูปใหม่ถ้ามี
      String? finalImageUrl = _imageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadImage();
      }

      final provider = Provider.of<FishLogProvider>(context, listen: false);
      final success = await provider.updateFishLog(
        documentId: widget.documentId!,
        detail: _detailController.text,
        imageURL: finalImageUrl,
      );

      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('แก้ไขข้อมูลสำเร็จ')),
        );
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการแก้ไขข้อมูล: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เกิดข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _imageUrl;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('fishlog_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(_selectedImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $e');
      return null;
    }
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รูปภาพ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildImageContent(),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('เลือกรูปภาพ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
            if (_selectedImage != null || _imageUrl != null) ...[
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    if (_currentFishLog != null) {
                      // รีเซ็ตกลับไปใช้รูปเดิม
                      final data = _currentFishLog!.data() as Map<String, dynamic>;
                      _imageUrl = data['imageURL'];
                    } else {
                      _imageUrl = null;
                    }
                  });
                },
                icon: Icon(Icons.clear),
                label: Text('ลบ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    // ถ้ามีรูปใหม่ที่เลือก
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    }
    
    // ถ้ามีรูปเดิมจากฐานข้อมูล
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 50),
                  Text('ไม่สามารถโหลดรูปภาพได้'),
                ],
              ),
            );
          },
        ),
      );
    }
    
    // ถ้าไม่มีรูป
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo, color: Colors.grey, size: 50),
          SizedBox(height: 8),
          Text(
            'ไม่มีรูปภาพ',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขบันทึกการตกปลา'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateFishLog,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _detailController,
                        decoration: InputDecoration(
                          labelText: 'รายละเอียด',
                          border: OutlineInputBorder(),
                          hintText: 'กรอกรายละเอียดการตกปลา...',
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกรายละเอียด';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // ส่วนแสดงและจัดการรูปภาพ
                      _buildImageSection(),
                      SizedBox(height: 20),

                      // ปุ่มบันทึกและยกเลิก
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text('ยกเลิก'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateFishLog,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text('บันทึก'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }
}