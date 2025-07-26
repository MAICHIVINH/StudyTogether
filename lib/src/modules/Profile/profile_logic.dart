import 'dart:async';
import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/responsitories/get_post.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_logic.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:rxdart/rxdart.dart' as rx;

class ProfileLogic {
  final FirebaseDatabaseService databaseService;
  ProfileLogic({required this.databaseService});
  final cloudinary = Cloudinary.signedConfig(
    apiKey: "YOUR_API_KEY",
    apiSecret: "YOUR_API_SECRET",
    cloudName: "YOUR_CLOUD_NAME",
  );
  StreamSubscription<DatabaseEvent>? userSubscription;

  Future<bool> _checkEmailExists(String email, String currentUid) async {
    try {
      final snapshot = await databaseService.getData('users');
      if (snapshot == null) return false;

      final users = Map<String, dynamic>.from(snapshot);
      for (var userEntry in users.entries) {
        if (userEntry.key != currentUid && userEntry.value['email'] == email) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Lỗi khi kiểm tra email: $e");
      return false;
    }
  }

  Future<String?> uploadImage(File selectedImage, String uid) async {
    try {
      final fileBytes = await selectedImage.readAsBytes();
      final response = await cloudinary.upload(
        file: selectedImage.path,
        fileBytes: fileBytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'user_avatars/$uid',
        fileName: '${DateTime.now().millisecondsSinceEpoch}.jpg',
        progressCallback: (count, total) {
          print('📤 Tiến trình tải lên: $count/$total');
        },
      );

      if (response.isSuccessful && response.secureUrl != null) {
        print('✅ Tải ảnh lên Cloudinary thành công!');
        return response.secureUrl;
      } else {
        print('⚠️ Tải ảnh thất bại: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi tải lên Cloudinary: $e');
      Get.snackbar('Lỗi', 'Không thể tải ảnh lên: $e');
      return null;
    }
  }

  Future<void> updateUser(
    String name,
    String email,
    File? selectedImage,
  ) async {
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) {
        Get.snackbar("Lỗi", "Không tìm thấy người dùng hiện tại");
        return;
      }

      final currentUserSnapshot = await databaseService.getData(
        "users/$currentUid",
      );
      if (currentUserSnapshot == null) {
        Get.snackbar("Lỗi", "Không tìm thấy dữ liệu người dùng");
        return;
      }

      final currentUserData = Map<String, dynamic>.from(currentUserSnapshot);
      final currentEmail = currentUserData['email'];

      if (email != currentEmail) {
        if (await _checkEmailExists(email, currentUid)) {
          Get.snackbar("Lỗi", "email đã tồn tại ");
          return;
        }
      }

      String photoUrl = currentUserData['photoUrl'] ?? "";

      if (selectedImage != null) {
        final uploadedImageUrl = await uploadImage(selectedImage, currentUid);
        if (uploadedImageUrl != null) {
          photoUrl = uploadedImageUrl;
        } else {
          Get.snackbar("Lỗi", "Không thể tải ảnh lên");
          return;
        }
      }

      final dataRequies = {"name": name, "email": email, "photoUrl": photoUrl};
      await databaseService.updateData(
        path: "users/$currentUid",
        data: dataRequies,
      );
    } catch (e) {
      Get.snackbar("Lỗi", "$e");
      return;
    }
  }

  Stream<Map<String, dynamic>?> userStream(String? uidFriend) {
    final uid = uidFriend ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    final ref = databaseService.database.ref("users/$uid");
    return ref.onValue.map((event) {
      final snapshot = event.snapshot.value;
      if (snapshot != null) {
        return Map<String, dynamic>.from(snapshot as Map);
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> fetchUser(String? uidFriend) async {
    try {
      if (uidFriend == null) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return null;

        final snapshot = await databaseService.getData("users/$uid");
        if (snapshot != null) {
          return Map<String, dynamic>.from(snapshot);
        }
      } else {
        final snapshot = await databaseService.getData("users/$uidFriend");
        if (snapshot != null) {
          return Map<String, dynamic>.from(snapshot);
        }
      }

      return null;
    } catch (e) {
      print("Lỗi khi lấy user: $e");
      return null;
    }
  }

  Future<void> fetchUserPosts(String userUid) async {
    try {
      final databaseService = FirebaseDatabaseService();
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      // Chỉ lấy hiddenPosts của người dùng hiện tại
      final hiddenSnapshot =
          currentUid != null
              ? await databaseService.getData("hiddenPosts/$currentUid")
              : null;
      final hiddenPostIds = hiddenSnapshot?.keys.toSet() ?? {};
      final postController = Get.put(PostController());

      final snapshot = await FirebaseDatabase.instance.ref("posts").get();
      final data = snapshot.value;

      if (data != null && data is Map) {
        final userPosts = <getPost>[];
        List<Future> fetchOriginalPosts = [];

        data.forEach((key, value) {
          if (value is Map && !hiddenPostIds.contains(key)) {
            final post = getPost.formJson(value);
            if (post.uid.value == userUid) {
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
              userPosts.add(post);
            }
          }
        });

        await Future.wait(fetchOriginalPosts);
        postController.setPost(userPosts);
        if (currentUid != null) {
          postController.checkLikedPosts(currentUid);
        }
      }
    } catch (e) {
      print("Lỗi khi lấy bài viết của người dùng: $e");
      Get.snackbar("Lỗi", "Không thể tải bài viết: $e");
    }
  }

  Stream<String> getFriendStatus(String uidFriend) {
    final uidUser = FirebaseAuth.instance.currentUser?.uid;
    if (uidUser == null || uidUser == uidFriend) {
      return Stream.value('none');
    }

    final friendStream = databaseService
        .listenToData("friends/$uidUser/$uidFriend")
        .map((event) => event.snapshot.exists ? 'friend' : null);

    final requestStream = databaseService
        .listenToData("friend_requests/$uidUser/$uidFriend")
        .map((event) {
          if (!event.snapshot.exists) return null;
          final data = event.snapshot.value;
          if (data is Map && data.containsKey('status')) {
            return data['status'] as String;
          }
          return null;
        });

    return rx.Rx.combineLatest2<String?, String?, String>(
      friendStream,
      requestStream,
      (friend, request) {
        if (friend == 'friend') return 'friend';
        if (request == 'pending') return 'pending';
        if (request == 'received') return 'received';
        return 'none';
      },
    );
  }

  Future<int> countPostsByUid(String uid) async {
    try {
      final snapshot = await databaseService.getData('posts');
      if (snapshot == null) return 0;

      final allPosts = Map<String, dynamic>.from(snapshot);
      final userPosts = allPosts.values.where((post) {
        return post['uid'] == uid;
      });
      return userPosts.length;
    } catch (e) {
      print("Lỗi khi đếm bài viết: $e");
      return 0;
    }
  }

  Stream<int> getFriendCountStream(String uid) {
    return databaseService.listenToData("friends/$uid").map((event) {
      final data = event.snapshot.value;
      if (data == null) return 0;

      final friendsMap = data as Map<dynamic, dynamic>;
      return friendsMap.length;
    });
  }

  Stream<int> getFriendRequestCountStream(String uid) {
    return databaseService.listenToData("friend_requests/$uid").map((event) {
      final data = event.snapshot.value;
      if (data == null) return 0;

      final requestsMap = data as Map<dynamic, dynamic>;
      int count = 0;

      requestsMap.forEach((senderId, value) {
        if (value is Map && value['status'] == 'pending') {
          count++;
        }
      });

      return count;
    });
  }
}
