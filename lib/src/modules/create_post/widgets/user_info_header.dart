import 'package:flutter/material.dart';

class UserInfoHeader extends StatelessWidget {
  final String imageUrl;
  final String username;

  const UserInfoHeader({
    super.key,
    required this.imageUrl,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl)
                      : AssetImage(imageUrl) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(Icons.public, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "Công khai",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
