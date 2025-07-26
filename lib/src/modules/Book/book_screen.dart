import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Book/book_screen_logic.dart';
import 'package:studytogether_v1/src/modules/Book/widget/add_book_page.dart';
import 'package:studytogether_v1/src/modules/Book/widget/book_fliter.dart';
import 'package:studytogether_v1/src/modules/Book/widget/book_item.dart';

class BookTab extends StatefulWidget {
  const BookTab({super.key});

  @override
  State<BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> {
  final BookLogic logic = Get.find<BookLogic>();

  String selectedGenre = "Tất cả";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> getGenres(List<Map<String, dynamic>> books) {
    final allGenres =
        books.map((book) => book["genre"] as String).toSet().toList();
    allGenres.sort();
    return ["Tất cả", ...allGenres];
  }

  List<Map<String, dynamic>> filterBooks(List<Map<String, dynamic>> books) {
    return books.where((book) {
      final matchGenre =
          selectedGenre == "Tất cả" || book["genre"] == selectedGenre;
      final matchKeyword = (book["title"] ?? "").toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchGenre && matchKeyword;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang tài liệu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBookPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: logic.listenToBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final books = snapshot.data ?? [];
          final genres = getGenres(books);

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                BookFilter(
                  genres: genres,
                  selectedGenre: selectedGenre,
                  onGenreChanged:
                      (genre) => setState(() => selectedGenre = genre),
                  searchController:
                      _searchController, // Truyền controller vào đây
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      final filteredBooks = filterBooks(books);
                      return filteredBooks.isEmpty
                          ? const Center(child: Text("Không có sách nào"))
                          : GridView.builder(
                            itemCount: filteredBooks.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              return BookItem(book: book);
                            },
                          );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
