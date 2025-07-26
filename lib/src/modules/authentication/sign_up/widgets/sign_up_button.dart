import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_logic.dart';

class SignUpSubmitButton extends StatelessWidget {
  const SignUpSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpLogic>();

    return Obx(
      () =>
          controller.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: controller.handleSignUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Đăng ký', style: TextStyle(fontSize: 16)),
              ),
    );
  }
}
