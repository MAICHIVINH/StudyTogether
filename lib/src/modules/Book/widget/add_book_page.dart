import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studytogether_v1/src/modules/Book/book_screen_logic.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String author = "";
  int year = DateTime.now().year;
  String genre = "";
  String content = "";
  File? coverImage;
  File? documentFile;
  bool isLoading = false;
  final logic = Get.find<BookLogic>();
  final ImagePicker _picker = ImagePicker();

  final List<String> genres = [
    "Toán học",
    "Vật lý",
    "Hóa học",
    "Ngữ văn",
    "Ngoại ngữ",
    "Tin học",
    "Kỹ năng học tập",
  ];

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowCompression: true,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      const maxSizeInBytes = 10 * 1024 * 1024;

      if (await file.length() > maxSizeInBytes) {
        Get.snackbar(
          "Lỗi",
          "Tài liệu quá lớn (tối đa 10MB).",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }
      setState(() {
        documentFile = file;
      });
    }
  }

  Future<void> addBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        isLoading = true;
      });
      try {
        await logic.addBook(
          title: title,
          author: author,
          year: year,
          genre: genre,
          content: content,
          coverImage: coverImage,
          documentFile: documentFile,
        );
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          "Thành công",
          "Đã thêm sách!",
          snackPosition: SnackPosition.BOTTOM,
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          "Lỗi",
          "Không thể thêm sách: $e",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm tài liệu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Tên sách"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Không được để trống"
                            : null,
                onSaved: (value) => title = value ?? "",
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Tác giả"),
                onSaved: (value) => author = value ?? "",
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Năm xuất bản"),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || int.tryParse(value) == null
                            ? "Vui lòng nhập số hợp lệ"
                            : null,
                onSaved:
                    (value) =>
                        year = int.tryParse(value ?? "") ?? DateTime.now().year,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Thể loại"),
                value: genre.isEmpty ? null : genre,
                items:
                    genres
                        .map(
                          (g) => DropdownMenuItem<String>(
                            value: g,
                            child: Text(g),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    genre = value ?? "";
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Vui lòng chọn thể loại"
                            : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Nội dung/Mô tả"),
                maxLines: 4,
                onSaved: (value) => content = value ?? "",
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      coverImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              coverImage!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          )
                          : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Thêm ảnh bìa",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: pickDocument,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child:
                        documentFile != null
                            ? Text(
                              "Tệp đã chọn: ${documentFile!.path.split('/').last}",
                              style: const TextStyle(color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            )
                            : const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Thêm tài liệu",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : addBook,
                child: const Text("Thêm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
