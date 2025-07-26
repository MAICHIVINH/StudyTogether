import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/modules/home/story_view/story_view_screen.dart';

class UserStory extends StatelessWidget {
  final String imageUrl;

  const UserStory({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewScreen(imageUrl: imageUrl),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 27,
                backgroundImage: AssetImage(imageUrl),
              ),
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
