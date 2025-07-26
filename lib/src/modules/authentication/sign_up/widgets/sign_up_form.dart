import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_logic.dart';

class SignUpFormFields extends StatelessWidget {
  const SignUpFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpLogic>();
    void showImagePickerOptions(BuildContext context, SignUpLogic controller) {
      showModalBottomSheet(
        context: context,
        builder:
            (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text('Chụp ảnh'),
                    onTap: () {
                      controller.pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('Chọn từ thư viện'),
                    onTap: () {
                      controller.pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
      );
    }

    return Column(
      children: [
        Obx(
          () => GestureDetector(
            onTap: () => showImagePickerOptions(context, controller),
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  controller.selectedImage.value != null
                      ? FileImage(controller.selectedImage.value!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
              child:
                  controller.selectedImage.value == null
                      ? const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      )
                      : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: "Họ và tên",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? "Vui lòng nhập họ và tên"
                      : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: "Nhập email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Vui lòng nhập email";
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: controller.toggleObscurePassword,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Vui lòng nhập mật khẩu';
              if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => TextFormField(
            controller: controller.changePasswordController,
            obscureText: controller.obscureChangePassword.value,
            decoration: InputDecoration(
              labelText: 'Nhập lại mật khẩu',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: controller.toggleObscureChangePassword,
                icon: Icon(
                  controller.obscureChangePassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Vui lòng nhập mật khẩu';
              if (value != controller.passwordController.text) {
                return 'Mật khẩu nhập lại không khớp';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value:
              controller.roleController.text.isEmpty
                  ? 'sinh viên'
                  : controller.roleController.text,
          decoration: InputDecoration(
            labelText: "Vai trò (mặc định: sinh viên)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.school),
          ),
          items:
              ['học sinh', 'sinh viên', 'giáo viên']
                  .map(
                    (role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.roleController.text = value;
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn vai trò';
            }
            return null;
          },
        ),
      ],
    );
  }
}
