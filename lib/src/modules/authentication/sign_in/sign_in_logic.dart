import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studytogether_v1/Routes/app_router.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';

class SignInLogic extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isLoading = false.obs;
  var obscurePassword = true.obs;

  final _auth = FirebaseAuth.instance;
  final FirebaseDatabaseService databaseService;
  SignInLogic({required this.databaseService});
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
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
      // await userController.loadUser();
      print("Username : ${userController.name}");
    } else {
      print("Không tìm thấy dữ liệu user với uid $uid");
    }
  }

  Future<void> handleSignIn() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;

        if (user != null) {
          await fetchUserData(user.uid);
          isLoading.value = false;

          Get.offNamed(AppRouter.home);
        } else {
          isLoading.value = false;
          Get.snackbar(
            "Đăng nhập thất bại",
            "Không thể lấy thông tin người dùng.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } on FirebaseAuthException catch (e) {
        print("Lỗi: $e");
        isLoading.value = false;
        String errorMessage;
        switch (e.code) {
          case 'invalid-credential':
            errorMessage =
                "Thông tin đăng nhập không đúng, vui lòng kiểm tra email và mật khẩu.";
            break;
          case 'invalid-email':
            errorMessage = "Email không hợp lệ.";
            break;
          case 'network-request-failed':
            errorMessage = "Kết nối mạng thất bại. Vui lòng kiểm tra kết nối.";
            break;
          default:
            errorMessage = 'Lỗi đăng nhập: ${e.message}';
        }

        Get.snackbar(
          "Đăng nhập thất bại 1",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  // sign_in with google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('Google User: $googleUser');
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google Auth: ${googleAuth.accessToken}, ${googleAuth.idToken}');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Credential created: $credential');
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      print("User 1 $userCredential");

      User? user = userCredential.user;
      if (user != null) {
        fetchUserData(user.uid);
        isLoading.value = false;

        Get.offNamed(AppRouter.home);
      }
    } catch (e) {
      isLoading.value = false;
      print("Lỗi");
      print(e);
      Get.snackbar("Đăng nhập thất bại", e.toString());
    }
  }
}
