import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/modules/user_story/home_userStory.dart';

class UserStoriesList extends StatelessWidget {
  final List<Map<String, String>> users;
  const UserStoriesList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserStory(imageUrl: users[index]["image"]!);
        },
      ),
    );
  }
}
