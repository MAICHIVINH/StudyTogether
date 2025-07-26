import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/modules/Book/widget/book_detail.dart';

class BookItem extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isLocal = book["isLocal"] == true;
    final coverPath = book["coverUrl"];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
        );
      },
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 165,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  isLocal
                      ? Image.file(
                        File(coverPath),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.book, size: 50),
                      )
                      : Image.network(
                        coverPath ?? "",
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.book, size: 50),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book["title"],
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(book["author"], style: const TextStyle(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "${book["year"]}",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}