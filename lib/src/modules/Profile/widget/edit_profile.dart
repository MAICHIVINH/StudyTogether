import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_logic.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_in/sign_in_logic.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_logic.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';

class EditProfileDialog extends StatefulWidget {
  final ProfileLogic logic;
  const EditProfileDialog({super.key, required this.logic});

  @override
  State<EditProfileDialog> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<EditProfileDialog> {
  final SignUpLogic signUpLogic = SignUpLogic(
    databaseService: FirebaseDatabaseService(),
  );
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  File? _image;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await widget.logic.fetchUser(null);
    setState(() {
      _nameController.text = userData!['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _currentImageUrl = userData['photoUrl'];
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.logic.updateUser(
          _nameController.text,
          _emailController.text,
          _image,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cập nhật hồ sơ thành công')));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa hồ sơ'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _image != null
                          ? FileImage(_image!)
                          : _currentImageUrl != null
                          ? NetworkImage(_currentImageUrl!)
                          : null,
                  child:
                      _image == null && _currentImageUrl == null
                          ? Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên'),
                validator:
                    (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập email';
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hủy'),
        ),
        ElevatedButton(onPressed: _saveProfile, child: Text('Lưu')),
      ],
    );
  }
}
