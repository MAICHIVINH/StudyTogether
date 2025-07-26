import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_logic.dart';
import 'package:studytogether_v1/src/modules/Profile/widget/profile_action.dart';
import 'package:studytogether_v1/src/modules/Profile/widget/profile_header.dart';
import 'package:studytogether_v1/src/modules/Profile/widget/profile_photo.dart';
import 'package:studytogether_v1/src/modules/Profile/widget/profile_suggestions.dart';
import 'package:studytogether_v1/src/modules/home/widget/post_feed_list.dart';

class ProfileTab extends StatefulWidget {
  final String? uidFriend;
  const ProfileTab({super.key, required this.uidFriend});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final logic = ProfileLogic(databaseService: FirebaseDatabaseService());
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserPosts();
    isLoading = false;
  }

  Future<void> loadUserPosts() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetUid = widget.uidFriend ?? currentUid;
    if (targetUid != null) {
      await logic.fetchUserPosts(targetUid);
    }
  }

  final Map<String, dynamic> mockUser = const {
    'username': 'test.078',
    'fullname': 'Test',
    'avatar': 'https://link-to-avatar.png',
    'posts': 50,
    'followers': 150,
    'following': 0,
  };

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    bool isOwner = widget.uidFriend == null || widget.uidFriend == currentUid;
    final targetUid = widget.uidFriend ?? currentUid;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: logic.userStream(widget.uidFriend),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data;
            if (userData == null) {
              return const Center(child: Text("Không tìm thấy người dùng"));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(user: userData ?? mockUser),
                  const SizedBox(height: 8),
                  ProfileActions(isOwner: isOwner, uidFriend: widget.uidFriend),
                  const SizedBox(height: 20),
                  // ProfileSuggestions(suggestions: mockSuggestions),
                  const Divider(color: Colors.black),
                  // ProfilePhotos(images: postImages),
                  targetUid != null
                      ? PostFeedList(uid: targetUid)
                      : const Center(child: Text("Không thể tải bài viết")),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
