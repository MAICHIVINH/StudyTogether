import 'package:flutter/material.dart';

class BookFilter extends StatelessWidget {
  final List<String> genres;
  final String selectedGenre;
  final Function(String) onGenreChanged;
  final TextEditingController searchController;

  const BookFilter({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreChanged,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController, // <- dùng controller ở đây
          decoration: const InputDecoration(
            labelText: 'Tìm kiếm tài liệu',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Thể loại",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedGenre,
          isExpanded: true,
          items:
              genres
                  .map(
                    (genre) =>
                        DropdownMenuItem(value: genre, child: Text(genre)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onGenreChanged(value);
          },
        ),
      ],
    );
  }
}
