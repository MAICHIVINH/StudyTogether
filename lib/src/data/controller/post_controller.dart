import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:studytogether_v1/src/data/responsitories/get_post.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';

class PostController extends GetxController {
  var posts = <getPost>[].obs;
  var likedPosts = <String, bool>{}.obs;

  void setPost(List<getPost> postList) {
    postList.sort((a, b) {
      return b.createAt!.compareTo(a.createAt!);
    });
    posts.value = postList;
  }

  Future<void> checkLikedPosts(String uid) async {
    try {
      for (var post in posts) {
        final ref =
            await FirebaseDatabase.instance
                .ref("likes/${post.id.value}/$uid")
                .get();
        likedPosts[post.id.value] = ref.exists;
      }
      likedPosts.refresh(); // Cập nhật giao diện
    } catch (e) {
      print("Lỗi kiểm tra trạng thái thích: $e");
    }
  }

  Future<void> toggleLike(String uid, String postId, bool isLiked) async {
    try {
      final ref = FirebaseDatabase.instance.ref("likes/$postId/$uid");
      if (isLiked) {
        await ref.remove();
        likedPosts[postId] = false;
      } else {
        await ref.set(true);
        likedPosts[postId] = true;
      }
      likedPosts.refresh(); // Cập nhật giao diện
    } catch (e) {
      print("Lỗi chuyển đổi trạng thái thích: $e");
    }
  }

  void clearPosts() {
    posts.clear();
  }
}
