import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studytogether_v1/Routes/app_router.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';

class SignUpLogic extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController changePasswordController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  var selectedImage = Rx<File?>(null);
  var imageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureChangePassword = true.obs;

  final _auth = FirebaseAuth.instance;
  final FirebaseDatabaseService databaseService;
  final cloudinary = Cloudinary.signedConfig(
    apiKey: "YOUR_API_KEY",
    apiSecret: "YOUR_API_SECRET",
    cloudName: "YOUR_CLOUD_NAME",
  );

  SignUpLogic({required this.databaseService});

  @override
  void onClose() {
    // TODO: implement onClose
    emailController.dispose();
    changePasswordController.dispose();
    passwordController.dispose();
    nameController.dispose();
    roleController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleObscureChangePassword() {
    // Thêm hàm để ẩn/hiện mật khẩu nhập lại
    obscureChangePassword.value = !obscureChangePassword.value;
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<String?> uploadImage(String uid) async {
    if (selectedImage.value == null) return null;
    try {
      final fileBytes = await selectedImage.value!.readAsBytes();
      final response = await cloudinary.upload(
        file: selectedImage.value!.path,
        fileBytes: fileBytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'user_avatars/$uid',
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        progressCallback: (count, total) {
          print('📤 Tiến trình tải lên: $count/$total');
        },
      );

      if (response.isSuccessful && response.secureUrl != null) {
        print('✅ Tải ảnh lên Cloudinary thành công!');
        return response.secureUrl;
      } else {
        print('⚠️ Tải ảnh thất bại: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi tải lên Cloudinary: $e');
      Get.snackbar('Lỗi', 'Không thể tải ảnh lên: $e');
      return null;
    }
  }

  Future<void> fetchUserData(String uid) async {
    final data = await databaseService.getData("users/$uid");
    if (data != null) {
      print("User data: $data");
      // xử lý dữ liệu, ví dụ:
      final email = data["email"];
      final name = data["name"];
      final photoUrl = data["photoUrl"];

      final userController = Get.find<UserController>();
      userController.setUser(
        uid: uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
      );
    } else {
      print("Không tìm thấy dữ liệu user với uid $uid");
    }
  }

  Future<void> handleSignUp() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
        User? user = userCredential.user;
        if (user != null) {
          final photoUrl = await uploadImage(user.uid) ?? '';
          print(
            "Uid: ${user.uid} || name: ${nameController.text} || photoUrl:$photoUrl ",
          );
          await databaseService.addData(
            path: "users/${user.uid}",
            data: {
              "uid": user.uid,
              "name": nameController.text,
              "email": user.email,
              "photoUrl": photoUrl,
              "provider": "email",
              "role":
                  roleController.text == "" ? "student" : roleController.text,
            },
          );
          fetchUserData(user.uid);
        }
        isLoading.value = false;

        Get.offNamed(AppRouter.home);
      } catch (e) {
        print("Lỗi đăng ký: $e");
        Get.snackbar("Đăng ký thất bại", e.toString());
      }
    }
  }
}
