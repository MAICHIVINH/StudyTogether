import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CreatePostLogic {
  final FirebaseDatabaseService databaseService;
    final cloudinary = Cloudinary.signedConfig(
    apiKey: "YOUR_API_KEY",
    apiSecret: "YOUR_API_SECRET",
    cloudName: "YOUR_CLOUD_NAME",
  );

  CreatePostLogic(this.databaseService);

  Future<List<Map<String, String>>> uploadAllMedia(
    List<AssetEntity> assets,
    String uid,
  ) async {
    List<Map<String, String>> mediaList = [];

    for (final asset in assets) {
      final file = await asset.file;

      if (file == null) continue;

      final fileBytes = await file.readAsBytes();
      final type =
          asset.type == AssetType.video
              ? CloudinaryResourceType.video
              : CloudinaryResourceType.image;

      try {
        final response = await cloudinary.upload(
          file: file.path,
          fileBytes: fileBytes,
          resourceType: type,
          folder: 'posts/$uid',
          fileName: '${DateTime.now().millisecondsSinceEpoch}',
          progressCallback: (count, total) {
            print('📤 Upload progress: $count/$total');
          },
        );

        if (response.isSuccessful) {
          print('❌ Thêm dữ liệu thành công!');

          mediaList.add({'url': response.secureUrl ?? '', 'type': type.name});
        } else {
          print('⚠️ Upload failed: ${response.error}');
        }
      } catch (e) {
        print('❌ Lỗi khi upload lên Cloudinary: $e');
      }
    }

    return mediaList;
  }

  Future<void> submitPost({
    required String content,
    required List<AssetEntity> selectedAssets,
  }) async {
    final postId = const Uuid().v4();
    final timestamp = DateTime.now().toIso8601String();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final mediaList = await uploadAllMedia(selectedAssets, uid ?? "error");
      if (uid == null) throw Exception("Người dùng chưa đăng nhập.");

      final userSnapshot =
          await FirebaseDatabase.instance.ref('users/$uid').get();
      final userData = userSnapshot.value as Map<dynamic, dynamic>?;

      if (userData == null)
        throw Exception("Không tìm thấy thông tin người dùng.");
      final data = {
        'id': postId,
        'uid': uid,
        'username': userData["name"],
        'avatarUrl': userData["photoUrl"],
        'content': content,
        'media': mediaList,
        'createdAt': timestamp,
      };

      await databaseService.addData(path: "posts/$postId", data: data);
      print('✅ Đăng bài thành công!');
    } catch (e) {
      print('❌ Lỗi khi đăng bài: $e');
      // rethrow;
    }
  }
}
