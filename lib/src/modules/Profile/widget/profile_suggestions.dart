import 'package:flutter/material.dart';

class ProfileSuggestions extends StatelessWidget {
  final List<Map<String, String>> suggestions;

  const ProfileSuggestions({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Khám phá mọi người",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = suggestions[index];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(item['avatar']!),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['name']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {},
                    child: const Text('Theo dõi'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
