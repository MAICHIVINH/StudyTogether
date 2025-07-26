import 'package:flutter/material.dart';

class PostTextField extends StatelessWidget {
  final TextEditingController controller;

  const PostTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 6,
      decoration: const InputDecoration(
        hintText: "Bạn đang nghĩ gì?",
        border: InputBorder.none,
      ),
    );
  }
}
