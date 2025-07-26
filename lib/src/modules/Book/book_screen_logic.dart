import 'dart:io';

import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';

class BookLogic extends GetxController {
  final FirebaseDatabaseService databaseService;
  final cloudinary = Cloudinary.signedConfig(
    apiKey: "YOUR_API_KEY",
    apiSecret: "YOUR_API_SECRET",
    cloudName: "YOUR_CLOUD_NAME",
  );

  BookLogic(this.databaseService);

  Future<String?> uploadFile(
    File file,
    String folder,
    String bookId, {
    bool isImage = false,
  }) async {
    try {
      if (!await file.exists()) {
        throw Exception('File không tồn tại: ${file.path}');
      }

      final originalFileName = path.basename(file.path);
      final extension = path.extension(file.path).toLowerCase();
      final fileNameWithoutExtension = path.basenameWithoutExtension(
        originalFileName,
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final fileName =
          isImage
              ? '$fileNameWithoutExtension-$timestamp' // Không có phần mở rộng cho ảnh
              : '$fileNameWithoutExtension-$timestamp$extension';

      final response = await cloudinary.upload(
        file: file.path,
        resourceType:
            isImage ? CloudinaryResourceType.image : CloudinaryResourceType.raw,
        folder: '$folder/$bookId',
        fileName: fileName,
      );

      if (response.isSuccessful && response.secureUrl != null) {
        print('✅ Tải file lên Cloudinary thành công: ${response.secureUrl}');
        final urlWithoutExtension = response.secureUrl!.replaceAll(
          RegExp(r'\.\w+$'),
          '',
        );
        return response.secureUrl;
      } else {
        print('❌ Tải file thất bại: ${response.error}');
        throw Exception('Tải file thất bại: ${response.error}');
      }
    } catch (e) {
      print('❌ Lỗi khi tải file lên Cloudinary: $e');
      return null;
    }
  }

  Future<void> addBook({
    required String title,
    required String author,
    required int year,
    required String genre,
    required String content,
    File? coverImage,
    File? documentFile,
  }) async {
    try {
      final ref = databaseService.database.ref("books").push();
      final bookId = ref.key;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) throw Exception("Người dùng chưa đăng nhập.");

      final userSnapshot =
          await FirebaseDatabase.instance.ref('users/$uid').get();
      final userData = userSnapshot.value as Map<dynamic, dynamic>?;

      if (userData == null)
        throw Exception("Không tìm thấy thông tin người dùng.");
      if (bookId == null) {
        throw Exception('Không thể tạo ID cho sách');
      }

      String? imageUrl;
      print("Dữ liệu Image $coverImage");

      if (coverImage != null) {
        imageUrl = await uploadFile(
          coverImage,
          "books/images",
          bookId,
          isImage: true,
        );
        if (imageUrl == null) {
          throw Exception('Tải ảnh bìa thất bại');
        }
      }

      String? documentUrl;
      print("Dữ liệu $documentFile");
      if (documentFile != null) {
        documentUrl = await uploadFile(
          documentFile,
          "books/documents",
          bookId,
          isImage: false,
        );
        if (documentUrl == null) {
          throw Exception('Tải file tài liệu thất bại');
        }
      }

      final bookData = {
        "id": bookId,
        "uid": uid,
        "poster": userData["name"],
        "title": title,
        "author": author,
        "year": year,
        "genre": genre,
        "content": content,
        "coverUrl": imageUrl ?? "",
        "documentUrl": documentUrl ?? "",
        "createdAt": DateTime.now().toIso8601String(),
      };

      await ref.set(bookData);
      print('✅ Thêm sách thành công!');
    } catch (e) {
      print('❌ Lỗi khi thêm sách: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> listenToBooks() {
    return databaseService.listenToData('books').map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final books = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        books.add({'id': key, ...Map<String, dynamic>.from(value)});
      });
      return books;
    });
  }
}
