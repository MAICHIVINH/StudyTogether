import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  void _downloadFile(BuildContext context, String url, bool isLocal) async {
    try {
      print("Dữ liệu tài liệu $url");
      if (url.isNotEmpty) {
        if (isLocal) {
          final file = File(url);

          if (await file.exists()) {
            final result = await OpenFile.open(file.path);
            if (result.type != ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Lỗi khi mở file: ${result.message}")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("File không tồn tại.")),
            );
          }
        } else {
          final uri = Uri.parse(url);

          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("URL không hợp lệ.")));
            return;
          }

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Không thể mở URL.")));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không có tài liệu để tải.")),
        );
      }
    } catch (e) {
      print("Lỗi khi load: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = book["isLocal"] == true;
    final coverPath = book["coverUrl"];

    return Scaffold(
      appBar: AppBar(
        title: Text(book["title"] ?? "Chi tiết sách"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Tải xuống',
            onPressed:
                () =>
                    _downloadFile(context, book["documentUrl"] ?? "", isLocal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      isLocal
                          ? Image.file(
                            File(coverPath),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.book, size: 60),
                          )
                          : Image.network(
                            coverPath ?? "",
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.book, size: 60),
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book["title"] ?? "Không rõ tiêu đề",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(Icons.person, "Tác giả", book["author"]),
                      _infoRow(Icons.category, "Thể loại", book["genre"]),
                      _infoRow(Icons.calendar_today, "Năm", "${book["year"]}"),
                      _infoRow(Icons.person, "Người đăng", book["poster"]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Giới thiệu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              book["content"] ?? "Không có mô tả cho cuốn sách này.",
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value ?? "Không rõ", overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
