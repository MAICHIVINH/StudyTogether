import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/responsitories/comment_model.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/data/responsitories/get_post.dart';

class HomeLogic extends GetxController {
  final FirebaseDatabaseService databaseService;
  HomeLogic({required this.databaseService});

  Future<void> toggleLikePost(String uid, String postId, bool isLiked) async {
    try {
      print("Dữ liệu trả về khi ẩn $uid và $postId");

      final ref = FirebaseDatabase.instance.ref("likes/$postId/$uid");
      final postSnapshot =
          await FirebaseDatabase.instance.ref('posts/$postId').get();
      final postData = postSnapshot.value as Map<dynamic, dynamic>?;
      if (postData == null) throw Exception("Không tìm thấy bài viết.");

      final postOwnerUid = postData['uid'];

      if (isLiked) {
        await ref.remove();
      } else {
        await ref.set(true);
        final userSnapshot =
            await FirebaseDatabase.instance.ref('users/$uid').get();
        final userData = userSnapshot.value as Map<dynamic, dynamic>?;

        if (userData == null)
          throw Exception("Không tìm thấy thông tin người dùng.");

        if (uid != postOwnerUid) {
          // Không gửi thông báo nếu người dùng thích bài của chính mình
          final notiRef =
              FirebaseDatabase.instance
                  .ref("notifications/$postOwnerUid")
                  .push();

          final dataNotification = {
            "type": "like",
            "postId": postId,
            "fromUid": uid,
            "fromName": userData['name'],
            "fromAvatar": userData['photoUrl'],
            "content": "đã thích bài viết của bạn",
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "isRead": false,
          };

          await notiRef.set(dataNotification);
        }
      }
    } catch (e) {
      print("Lỗi load Page: $e");
      // Get.snackbar("Lỗi load page", e.toString());
    }
  }

  Future<bool> isPostLiked(String uid, String postId) async {
    try {
      print("Dữ liệu trạng thái $uid và $postId");
      final ref =
          await FirebaseDatabase.instance.ref("likes/$postId/$uid").get();
      final userSnapshot =
          await FirebaseDatabase.instance.ref('users/$uid').get();
      final userData = userSnapshot.value as Map<dynamic, dynamic>?;
      final postSnapshot =
          await FirebaseDatabase.instance.ref('posts/$postId').get();
      final postData = postSnapshot.value as Map<dynamic, dynamic>?;
      if (postData == null) throw Exception("Không tìm thấy bài viết.");

      final postOwnerUid = postData['uid'];
      if (userData == null)
        throw Exception("Không tìm thấy thông tin người dùng.");

      if (uid != postOwnerUid) {
        // Không gửi thông báo nếu người dùng thích bài của chính mình
        final notiRef =
            FirebaseDatabase.instance.ref("notifications/$postOwnerUid").push();

        final dataNotification = {
          "type": "like",
          "postId": postId,
          "fromUid": uid,
          "fromName": userData['name'],
          "fromAvatar": userData['photoUrl'],
          "content": "đã thích bài viết của bạn",
          "createdAt": DateTime.now().millisecondsSinceEpoch,
          "isRead": false,
        };

        await notiRef.set(dataNotification);
      }
      return ref.exists;
    } catch (e) {
      print("Lỗi load Page: $e");
      // Get.snackbar("Looix load page", e.toString());
      return false;
    }
  }

  // Trả về Stream<int> để lắng nghe realtime số lượng like của 1 bài post
  Stream<int> getLikeCountStream(String postId) {
    return databaseService.listenToData("likes/$postId").map((event) {
      final data = event.snapshot.value;
      if (data == null) return 0;
      return (data as Map).length;
    });
  }

  // hàm ẩn bải viết của 1 người mà không ảnh hưởng đến tài khoản khác
  Future<void> hidePost(String postId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Người dùng chưa đăng nhập.");

      await FirebaseDatabase.instance.ref("hiddenPosts/$uid/$postId").set(true);

      Get.snackbar(
        "Thành công",
        "Bài viết đã được ẩn.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print("Lỗi load Page: $e");
      // Get.snackbar("Looix load page", e.toString());
    }
  }

  // Hàm load dữ liệu
  Future<void> fetchPostData(String uid) async {
    try {
      final postController = Get.find<PostController>();
      final posts = <getPost>[];
      final hiddenSnapshot = await databaseService.getData("hiddenPosts/$uid");
      final hiddenPostIds = hiddenSnapshot?.keys.toSet() ?? {};
      postController.posts.clear();
      databaseService.listenToData("posts").listen((DatabaseEvent event) async {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          posts.clear();

          List<Future> fetchOriginalPosts = [];

          data.forEach((key, value) {
            if (value is Map && !hiddenPostIds.contains(key)) {
              final post = getPost.formJson(value);

              if (post.postIdShare.value.isNotEmpty) {
                fetchOriginalPosts.add(
                  databaseService
                      .getData('posts/${post.postIdShare.value}')
                      .then((originalData) {
                        if (originalData != null) {
                          post.originalPost = getPost.formJson(originalData);
                        }
                      }),
                );
              }

              posts.add(post);
            }
          });

          await Future.wait(fetchOriginalPosts);

          postController.setPost(posts);
          postController.checkLikedPosts(uid);
        }
      });
    } catch (e) {
      print("Lỗi load Page: $e");
    }
  }

  Future<void> sharePost(String postId, String shareContent) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final originalPostData = await databaseService.getData('posts/$postId');
      if (originalPostData == null) {
        print("Bài viết gốc không tồn tại");
        return;
      }
      final userData = await databaseService.getData('users/$uid');
      if (userData == null) {
        print("Thông tin người dùng không tồn tại");
        return;
      }

      final newPostRef = databaseService.database.ref('posts').push();
      final newPostId = newPostRef.key;

      if (newPostId == null) {
        print("Không tạo được postId mới");
        return;
      }

      final sharedPostData = {
        'id': newPostId,
        'username': userData['name'],
        'avatarUrl': userData['photoUrl'],
        'content': shareContent,
        'uid': uid,
        'userNameByShare': originalPostData['username'],
        'uidByShare': originalPostData['uid'],
        'postIdByShare': originalPostData['id'],
        'contentByShare': originalPostData['content'],
        'avatarByShare': originalPostData['avatarUrl'],
        'media': originalPostData['media'] ?? [],
        'createdAt': DateTime.now().toIso8601String(),
      };

      await newPostRef.set(sharedPostData);

      // Gửi thông báo cho chủ sở hữu bài viết gốc
      final originalPostOwnerUid = originalPostData['uid'];
      if (uid != originalPostOwnerUid) {
        // Không gửi nếu người chia sẻ là chủ bài
        final notiRef =
            FirebaseDatabase.instance
                .ref("notifications/$originalPostOwnerUid")
                .push();

        final dataNotification = {
          "type": "share",
          "postId": postId,
          "fromUid": uid,
          "fromName": userData['name'],
          "fromAvatar": userData['photoUrl'],
          "content": "đã chia sẻ bài viết của bạn",
          "createdAt": DateTime.now().millisecondsSinceEpoch,
          "isRead": false,
        };

        await notiRef.set(dataNotification);
      }

      print("Chia sẻ bài viết thành công, postId mới: $newPostId");
    } catch (e) {
      print("Lỗi khi chia sẻ bài viết: $e");
    }
  }

  Future<List<Map<String, dynamic>>> searchUsersByName(String keyword) async {
    try {
      final ref = await FirebaseDatabase.instance.ref('users').get();

      if (ref.exists) {
        final data = ref.value as Map<dynamic, dynamic>;
        return data.values
            .where(
              (user) =>
                  user['name'] != null &&
                  user['name'].toString().toLowerCase().contains(
                    keyword.toLowerCase(),
                  ),
            )
            .map<Map<String, dynamic>>(
              (user) => Map<String, dynamic>.from(user),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi khi tìm kiếm người dùng: $e");
      return [];
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Người dùng chưa đăng nhập.");

      final userSnapshot =
          await FirebaseDatabase.instance.ref('users/$uid').get();
      final userData = userSnapshot.value as Map<dynamic, dynamic>?;

      if (userData == null)
        throw Exception("Không tìm thấy thông tin người dùng.");

      final postSnapshot =
          await FirebaseDatabase.instance.ref('posts/$postId').get();
      final postData = postSnapshot.value as Map?;
      if (postData == null) throw Exception("Không tìm thấy bài viết.");
      final postOwnerUid = postData['uid'];

      final commentId = FirebaseDatabase.instance.ref().push().key;

      final comment = {
        'uid': userData['uid'],
        'userName': userData['name'] ?? 'Unknown',
        'userAvatar': userData['photoUrl'],
        'content': content,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseDatabase.instance
          .ref('comments/$postId/$commentId')
          .set(comment);

      // await databaseService.addData(
      //   path: 'comments/$postId/$commentId',
      //   data: comment,
      // );

      if (uid != postOwnerUid) {
        final notiRef =
            FirebaseDatabase.instance.ref("notifications/$postOwnerUid").push();

        final dataNotification = {
          "type": "comment",
          "postId": postId,
          "fromUid": uid,
          "fromName": userData['name'],
          "fromAvatar": userData['photoUrl'],
          "content": "vừa bình luận vào bài viết của bạn",
          "createdAt": DateTime.now().millisecondsSinceEpoch,
          "isRead": false,
        };

        await notiRef.set(dataNotification);
      }
    } catch (e) {
      print("❌ Lỗi khi thêm comment: $e");
      rethrow;
    }
  }

  Stream<List<CommentModel>> listenToComments(String postId) async* {
    final commentsRef = FirebaseDatabase.instance.ref('comments/$postId');
    await for (final event in commentsRef.onValue) {
      final data = event.snapshot.value;

      // Kiểm tra nếu data là null hoặc không phải Map
      if (data == null || data is! Map<dynamic, dynamic>) {
        print("Dữ liệu không hợp lệ hoặc không có bình luận: $data");
        yield [];
        continue;
      }

      final commentList = <CommentModel>[];

      for (final entry in data.entries) {
        if (entry.value is! Map) {
          print("⚠️ Bình luận không đúng định dạng Map: ${entry.value}");
          continue;
        }

        final commentMap = Map<String, dynamic>.from(entry.value as Map);
        commentList.add(
          CommentModel(
            postId: postId,
            uid: commentMap['uid']?.toString() ?? '',
            userName: commentMap['userName']?.toString() ?? 'Unknown',
            userAvatar: commentMap['userAvatar']?.toString() ?? '',
            content: commentMap['content']?.toString() ?? '',
            timestamp:
                commentMap['createdAt'] is int
                    ? DateTime.fromMillisecondsSinceEpoch(
                      commentMap['createdAt'],
                    )
                    : DateTime.now(),
          ),
        );
      }
      yield commentList;
    }
  }

  Stream<int> getCommentCountStream(String postId) {
    return databaseService.listenToData("comments/$postId").map((event) {
      final data = event.snapshot.value;
      if (data == null) return 0;
      return (data as Map).length;
    });
  }

  Stream<List<Map<String, dynamic>>> listenToNotifications() async* {
    final uidUser = FirebaseAuth.instance.currentUser?.uid;

    final notificationsRef =
        FirebaseDatabase.instance.ref("notifications/$uidUser").onValue;

    await for (final item in notificationsRef) {
      final data = item.snapshot.value;

      if (data == null || data is! Map) {
        yield [];
        continue;
      }

      final notifications = <Map<String, dynamic>>[];

      (data).forEach((key, value) {
        if (value is Map) {
          final notification = Map<String, dynamic>.from(value);

          final type = notification['type'] ?? 'unknown';

          String message = '';

          switch (type) {
            case 'like':
              message =
                  '${notification['fromName']} đã thích bài viết của bạn.';
              break;
            case 'comment':
              message =
                  '${notification['fromName']} đã bình luận bài viết của bạn';
              break;
            case 'share':
              message =
                  '${notification['fromName']} đã chia sẻ bài viết của bạn.';
              break;
            case 'friend_request':
              message = '${notification['fromName']} đã gửi lời mời kết bạn';
              break;
            default:
              message = 'Bạn có một thông báo mới.';
          }

          notifications.add({
            'id': key,
            'type': type,
            'message': message,
            'fromUid': notification['fromUid'],
            'fromAvatar': notification['fromAvatar'],
            'createdAt': notification['createdAt'],
            'isRead': notification['isRead'] ?? false,
            'postId': notification['postId'] ?? '',
          });
        }
      });

      notifications.sort(
        (a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int),
      );

      yield notifications;
    }
  }

  Stream<int> getUnreadNotificationsCount() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(0);
    }

    return databaseService.listenToData("notifications/$uid").map((event) {
      final data = event.snapshot.value;
      if (data == null) return 0;

      final notifications = data as Map<dynamic, dynamic>;
      int unreadCount = 0;

      notifications.forEach((key, value) {
        if (value is Map && value['isRead'] == false) {
          unreadCount++;
        }
      });

      return unreadCount;
    });
  }

  Future<void> updateIsReadNotification(String uid) async {
    try {
      final notificationsRef = FirebaseDatabase.instance.ref(
        'notifications/$uid',
      );
      final snapshot = await notificationsRef.get();

      if (snapshot.exists) {
        final notifications = snapshot.value as Map<dynamic, dynamic>;
        final updates = <String, dynamic>{};

        notifications.forEach((key, value) {
          if (value is Map && value['isRead'] == false) {
            updates['$key/isRead'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await notificationsRef.update(updates);
          print("Đã cập nhật trạng thái isRead cho các thông báo.");
        }
      }
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái isRead: $e");
      rethrow;
    }
  }

  Future<void> addFriend(String receiverUid) async {
    final uidUser = FirebaseAuth.instance.currentUser?.uid;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> fromData = {
      "status": "pending",
      "timestamp": timestamp,
    };

    final Map<String, dynamic> toData = {
      "status": "received",
      "timestamp": timestamp,
    };

    try {
      if (uidUser != receiverUid) {
        await databaseService.addData(
          path: 'friend_requests/$uidUser/$receiverUid',
          data: fromData,
        );
        await databaseService.addData(
          path: 'friend_requests/$receiverUid/$uidUser',
          data: toData,
        );

        final userSnapshot =
            await FirebaseDatabase.instance.ref('users/$uidUser').get();
        final userData = userSnapshot.value as Map<dynamic, dynamic>?;

        final notiRef =
            FirebaseDatabase.instance.ref("notifications/$receiverUid").push();

        final dataNotification = {
          "type": "friend_request",
          "fromUid": uidUser,
          "fromName": userData!["name"] ?? 'Unknown',
          "fromAvatar": userData['photoUrl'],
          "content": "đã gửi lời mời kết bạn",
          "createdAt": timestamp,
          "isRead": false,
        };

        await notiRef.set(dataNotification);
      }
    } catch (e) {
      print("❌ Lỗi gửi lời mời kết bạn: $e");
      rethrow;
    }
  }

  Future<void> acceptFriendRequest({required String senderId}) async {
    try {
      final uidUser = FirebaseAuth.instance.currentUser?.uid;
      print("Dữ liệu của cả 2 $uidUser và $senderId");
      // Thêm cả hai vào danh sách bạn bè
      await FirebaseDatabase.instance
          .ref('friends/$uidUser/$senderId')
          .set(true);
      await FirebaseDatabase.instance
          .ref('friends/$senderId/$uidUser')
          .set(true);

      await FirebaseDatabase.instance
          .ref('friend_requests/$uidUser/$senderId')
          .remove();
      await FirebaseDatabase.instance
          .ref('friend_requests/$senderId/$uidUser')
          .remove();
    } catch (e) {
      print("❌ Lỗi chấp nhận kết bạn: $e");
      rethrow;
    }
  }

  Future<void> cancelFriendRequest(String receiverUid) async {
    final uidUser = FirebaseAuth.instance.currentUser?.uid;

    try {
      if (uidUser != null && uidUser != receiverUid) {
        // Xóa yêu cầu từ cả hai phía
        await FirebaseDatabase.instance
            .ref('friend_requests/$uidUser/$receiverUid')
            .remove();
        await FirebaseDatabase.instance
            .ref('friend_requests/$receiverUid/$uidUser')
            .remove();

        // Xóa thông báo nếu có
        final notificationsRef = FirebaseDatabase.instance
            .ref('notifications/$receiverUid')
            .orderByChild('fromUid')
            .equalTo(uidUser)
            .limitToLast(1);
        final snapshot = await notificationsRef.get();
        if (snapshot.exists) {
          for (var child in snapshot.children) {
            child.ref.remove();
          }
        }
      }
    } catch (e) {
      print("❌ Lỗi hủy lời mời kết bạn: $e");
      rethrow;
    }
  }
}
