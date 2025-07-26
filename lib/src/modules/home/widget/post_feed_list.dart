import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/responsitories/get_post.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:studytogether_v1/src/modules/home/post/home_post_item.dart';
import 'package:studytogether_v1/src/modules/home/post/shared_post_item.dart';

class PostFeedList extends StatelessWidget {
  final String uid;
  const PostFeedList({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final postController = Get.find<PostController>();
    final logic = HomeLogic(databaseService: FirebaseDatabaseService());

    // logic.fetchPostData(uid).then((_) {
    //   postController.checkLikedPosts(uid);
    // });

    return Obx(() {
      if (postController.posts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children:
            postController.posts.map((post) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child:
                    post.originalPost == null
                        ? PostItem(
                          // Bài viết gốc bình thường
                          key: ValueKey(post.id),
                          uid: post.uid.value,
                          postId: post.id.value,
                          username: post.userName.value,
                          avatarUrl: post.avatarUrl.value,
                          imageUrl: "assets/images/user1.jpg",
                          content: post.content.value,
                          media: post.media,
                        )
                        : SharedPostItem(
                          // Bài viết share
                          key: ValueKey(post.id),
                          uid: post.uid.value,
                          shareUid: post.uid.value,
                          postIdShare: post.postIdShare.value,
                          postId: post.id.value,
                          contentShare: post.shareContent.value,
                          content: post.content.value,
                          avatar: post.avatarUrl.value,
                          avatarShare: post.avatarShare.value,
                          media: post.media,
                          userName: post.userName.value,
                          userNameShare: post.userNameShare.value,
                        ),
              );
            }).toList(),
      );
    });
  }
}
