import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/responsitories/comment_model.dart';
import 'package:studytogether_v1/src/data/responsitories/get_post.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_screen.dart';
import 'package:studytogether_v1/src/modules/create_post/video_prview.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:studytogether_v1/src/modules/home/post/home_post_item.dart';
import 'package:studytogether_v1/src/modules/home/post/image_full_screen.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SharedPostItem extends StatefulWidget {
  final String uid;
  final String shareUid;
  final String avatarShare;
  final String avatar;
  final String content;
  final String contentShare;
  final String postId;
  final String postIdShare;
  final String userName;
  final String userNameShare;
  final List<Map<String, dynamic>> media;

  const SharedPostItem({
    super.key,
    required this.uid,
    required this.shareUid,
    required this.avatar,
    required this.avatarShare,
    required this.content,
    required this.contentShare,
    required this.postIdShare,
    required this.postId,
    required this.media,
    required this.userName,
    required this.userNameShare,
  });

  @override
  State<SharedPostItem> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SharedPostItem> {
  late HomeLogic logic;
  final PostController postController = Get.find<PostController>();
  final TextEditingController shareController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    logic = HomeLogic(databaseService: FirebaseDatabaseService());
  }

  void _showCommentForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.67,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Bình luận',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<CommentModel>>(
                  stream: logic.listenToComments(widget.postIdShare),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      print("Lỗi tải bình luận: ${snapshot.error}");
                      return Center(
                        child: Text('Lỗi tải bình luận: ${snapshot.error}'),
                      );
                    }

                    final comments = snapshot.data ?? [];

                    if (comments.isEmpty) {
                      return Center(child: Text('Chưa có bình luận nào'));
                    }

                    return ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                comment.userAvatar.startsWith('http')
                                    ? NetworkImage(comment.userAvatar)
                                    : AssetImage(comment.userAvatar)
                                        as ImageProvider,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.userName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                comment.timeAgo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(comment.content),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: () async {
                        final comment = commentController.text.trim();
                        if (comment.isNotEmpty) {
                          try {
                            await logic.addComment(widget.postIdShare, comment);
                            commentController.clear();
                            Get.snackbar(
                              "Thành công",
                              "Bình luận đã được gửi",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            Get.snackbar(
                              "Lỗi",
                              "Không thể gửi bình luận",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          }
                        } else {
                          Get.snackbar(
                            "Lỗi",
                            "Vui lòng nhập bình luận",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SizedBox(
            height: screenHeight * 0.33,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage:
                      widget.avatar.startsWith('http')
                          ? NetworkImage(widget.avatar)
                          : AssetImage(widget.avatar) as ImageProvider,
                  radius: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final content = shareController.text.trim();
                    if (content.isNotEmpty) {
                      logic.sharePost(widget.postIdShare, content);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng nhập nội dung chia sẻ'),
                        ),
                      );
                    }
                  },
                  child: Text('Chia sẻ'),
                ),
                TextField(
                  controller: shareController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Viết nội dung chia sẻ...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLiked = postController.likedPosts[widget.postIdShare] ?? false;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sharer's information
          ListTile(
            onTap: () {
              if (FirebaseAuth.instance.currentUser?.uid != widget.uid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileTab(uidFriend: widget.uid),
                  ),
                );
              }
            },
            leading: CircleAvatar(
              backgroundImage:
                  widget.avatar.startsWith('http')
                      ? NetworkImage(widget.avatar)
                      : AssetImage(widget.avatar) as ImageProvider,
              radius: 16,
            ),
            title: Text(
              widget.userName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('đã chia sẻ bài viết'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'hide') {
                  logic.hidePost(widget.postId);
                  logic.fetchPostData(widget.uid);
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'hide',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Ẩn bài viết'),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
          // Sharer's content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              widget.content,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          //   post
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original poster's info
                ListTile(
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser?.uid != widget.uid) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProfileTab(uidFriend: widget.uid),
                        ),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    backgroundImage:
                        widget.avatarShare.startsWith('http')
                            ? NetworkImage(widget.avatarShare)
                            : AssetImage(widget.avatarShare) as ImageProvider,
                    radius: 16,
                  ),
                  title: Text(
                    widget.userNameShare,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Original post media
                if (widget.media.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.media.length,
                      itemBuilder: (context, index) {
                        final item = widget.media[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: 200,
                            child: _buildMediaItem(item),
                          ),
                        );
                      },
                    ),
                  ),
                // Original post content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(widget.contentShare),
                ),
                // Interaction buttons for the original post
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:
                            () => postController.toggleLike(
                              FirebaseAuth.instance.currentUser!.uid,
                              widget.postIdShare,
                              isLiked,
                            ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: logic.getLikeCountStream(widget.postIdShare),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text('$count lượt thích');
                        },
                      ),

                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showCommentForm(context),
                        child: Icon(Icons.comment_outlined),
                      ),
                      SizedBox(width: 6),
                      StreamBuilder<int>(
                        stream: logic.getCommentCountStream(widget.postIdShare),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text('$count');
                        },
                      ),
                      SizedBox(width: 50),
                      GestureDetector(
                        onTap: () => _showShareForm(context),
                        child: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMediaItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      final type = item['type'] as String?;
      final url = item['url']?.toString();

      if (type == null || url == null) {
        return Center(child: Text('Dữ liệu media không hợp lệ'));
      }

      // fix(media): check file existence before rendering non-asset media
      final isAssetId = int.tryParse(url) != null;

      if (url.startsWith('http')) {
        return type == 'video'
            ? VideoPreview(videoUrl: url)
            : GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageFullScreenPage(imageUrl: url),
                  ),
                );
              },
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Center(child: Text('Lỗi tải hình ảnh từ mạng')),
              ),
            );
      }

      if (isAssetId) {
        return FutureBuilder<AssetEntity?>(
          future: AssetEntity.fromId(url),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text('Asset đã bị xóa hoặc không truy cập được'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              final asset = snapshot.data!;
              return FutureBuilder<File?>(
                future: asset.file,
                builder: (context, fileSnapshot) {
                  if (fileSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (fileSnapshot.hasData) {
                    final file = fileSnapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ImageFullScreenPage(imageFile: file),
                          ),
                        );
                      },
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Center(child: Text('Lỗi tải hình ảnh')),
                      ),
                    );
                  } else {
                    return Center(child: Text('Không thể lấy file từ asset'));
                  }
                },
              );
            } else {
              return Center(child: Text('Không tìm thấy asset với ID: $url'));
            }
          },
        );
      } else {
        // feat(media): handle errors when asset or file is not found
        final file = File(url);
        if (!file.existsSync()) {
          return Center(child: Text('Không tìm thấy file tại đường dẫn: $url'));
        }
        return SizedBox(
          width: 200,
          child:
              type == 'video'
                  ? VideoPreview(videoUrl: file)
                  : Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Center(child: Text('Lỗi tải hình ảnh')),
                  ),
        );
      }
    } else if (item is AssetEntity) {
      return FutureBuilder<File?>(
        future: item.file,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            final file = snapshot.data!;
            return SizedBox(
              width: 200,
              child:
                  item.type == AssetType.video
                      ? VideoPreview(videoUrl: file)
                      : Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Center(child: Text('Lỗi tải hình ảnh')),
                      ),
            );
          } else {
            return Center(child: Text('Không thể lấy file từ asset'));
          }
        },
      );
    }
    return Center(child: Text('Không hỗ trợ loại media này'));
  }

  // refactor(media): extract _buildMediaItem to handle different media types
  Future<AssetEntity?> _getAssetEntityFromId(String id) async {
    try {
      final asset = await AssetEntity.fromId(id);
      if (asset == null) {
        print("Không tìm thấy AssetEntity cho ID: $id");
      } else {
        print("Tìm thấy AssetEntity: ID = ${asset.id}, Type = ${asset.type}");
      }
      return asset;
    } catch (e) {
      print("Lỗi lấy AssetEntity: $e");
      return null;
    }
  }
}
