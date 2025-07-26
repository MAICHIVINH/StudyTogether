import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var uid = "".obs;
  var email = "".obs;
  var name = "".obs;
  var photoUrl = "".obs;

  void setUser({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
  }) {
    this.uid.value = uid;
    this.email.value = email;
    this.name.value = name ?? "";
    this.photoUrl.value = photoUrl ?? "";
  }

  void clearUser() {
    uid.value = "";
    email.value = "";
    name.value = "";
    photoUrl.value = "";
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      name.value = user.displayName ?? "No Name";
      photoUrl.value = user.photoURL ?? "";
      uid.value = user.uid;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadUser(); // tự động load khi controller được khởi tạo
  }
}
