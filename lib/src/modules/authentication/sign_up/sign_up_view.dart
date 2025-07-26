import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_logic.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/widgets/sign_up_title.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/widgets/sign_up_form.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/widgets/sign_up_button.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  late final SignUpLogic controller;

  @override
  void initState() {
    super.initState();
    final databaseService = ref.read(firebaseDatabaseServiceProvider);
    controller = Get.put(SignUpLogic(databaseService: databaseService));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  SignUpTitle(),
                  SizedBox(height: 40),
                  SignUpFormFields(),
                  SizedBox(height: 24),
                  SignUpSubmitButton(),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      'Đã có tài khoản? đăng nhập',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
