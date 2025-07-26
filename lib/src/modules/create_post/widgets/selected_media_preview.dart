import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/modules/home/post/image_full_screen.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../video_prview.dart';

class SelectedMediaPreview extends StatelessWidget {
  final List<AssetEntity> selectedFiles;
  final void Function(int index) onRemove;

  const SelectedMediaPreview({
    super.key,
    required this.selectedFiles,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedFiles.length,
        itemBuilder: (context, index) {
          final file = selectedFiles[index];
          return FutureBuilder<File?>(
            future: file.file,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                final fileData = snapshot.data!;

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (file.type == AssetType.image) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ImageFullScreenPage(imageFile: fileData),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child:
                            file.type == AssetType.video
                                ? VideoPreview(videoUrl: fileData)
                                : Image.file(
                                  fileData,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}
