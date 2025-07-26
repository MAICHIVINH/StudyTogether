import 'package:flutter/material.dart';

class ProfilePhotos extends StatelessWidget {
  final List<String> images;

  const ProfilePhotos({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder:
          (_, index) => Image.network(images[index], fit: BoxFit.cover),
    );
  }
}
