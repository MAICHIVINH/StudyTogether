import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/create_post/create_post_logic.dart';
import 'package:studytogether_v1/src/modules/create_post/video_prview.dart';
import 'package:studytogether_v1/src/modules/create_post/widgets/pick_media_button.dart';
import 'package:studytogether_v1/src/modules/create_post/widgets/post_text_field.dart';
import 'package:studytogether_v1/src/modules/create_post/widgets/selected_media_preview.dart';
import 'package:studytogether_v1/src/modules/create_post/widgets/user_info_header.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CreatePostScreen extends StatefulWidget {
  final String imageUrl;
  final String username;
  final String uid;
  const CreatePostScreen({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.uid,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  List<AssetEntity> _selectedFiles = [];
  bool isPostEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updatePostButtonState);
  }

  void _updatePostButtonState() {
    final hasText = _controller.text.trim().isNotEmpty;
    final hasMedia = _selectedFiles.isNotEmpty;
    final newValue = hasText || hasMedia;
    if (isPostEnabled != newValue) {
      setState(() {
        isPostEnabled = newValue;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (isPostEnabled) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final logic = CreatePostLogic(FirebaseDatabaseService());

        await logic.submitPost(
          content: _controller.text.trim(),
          selectedAssets: _selectedFiles,
        );

        Navigator.of(context).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Đăng bài thành công!")));
      } catch (e) {
        print("❌ Lỗi khi đăng bài: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Lỗi khi đăng bài: $e")));
      }
      // Navigator.of(context).pop();
    }
  }

  Future<void> _pickAsset() async {
    var photoStatus = await Permission.photos.request();
    var videoStatus = await Permission.videos.request();

    if (!photoStatus.isGranted) {
      photoStatus = await Permission.photos.request();
    }
    if (!videoStatus.isGranted) {
      videoStatus = await Permission.videos.request();
    }

    if (photoStatus.isGranted && videoStatus.isGranted) {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(),
      );
      if (result != null) {
        setState(() {
          _selectedFiles = result;
        });
        print("Đã chọn $_selectedFiles file.");
      } else {
        print("Không có file nào được chọn.");
      }
    } else {
      print("Quyền truy cập bị từ chối.");
      await openAppSettings();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Tạo bài viết",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // feat(ui): post button (enabled only when content is not empty)
          TextButton(
            onPressed: isPostEnabled ? _submitPost : null,
            child: Text(
              "Đăng",
              style: TextStyle(
                color: isPostEnabled ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// feat(user-info): display user avatar and username with post visibility options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UserInfoHeader(
                    imageUrl: widget.imageUrl,
                    username: widget.username,
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),

              const SizedBox(height: 20),

              // feat(content): text input field for post content
              PostTextField(controller: _controller),

              // feat(media): preview selected images or videos
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                SelectedMediaPreview(
                  selectedFiles: _selectedFiles,
                  onRemove: (index) {
                    setState(() {
                      _selectedFiles.removeAt(index);
                    });
                  },
                ),
              ],

              const SizedBox(height: 10),

              // feat(media): button to pick images/videos from the device
              PickMediaButton(onTap: _pickAsset),
            ],
          ),
        ),
      ),
    );
  }
}
