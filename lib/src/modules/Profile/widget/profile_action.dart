import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_logic.dart';
import 'package:studytogether_v1/src/modules/Profile/widget/edit_profile.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileActions extends StatelessWidget {
  final bool isOwner;
  final String? uidFriend;
  const ProfileActions({
    super.key,
    required this.isOwner,
    required this.uidFriend,
  });

  Future<void> handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();

      final userController = Get.find<UserController>();
      userController.setUser(uid: '', email: '', name: '', photoUrl: '');

      final postController = Get.find<PostController>();
      postController.clearPosts();

      Get.offAllNamed('/login');
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      Get.snackbar("Lỗi", "Không thể đăng xuất: $e");
    }
  }

  void _showEditProfileDialog(BuildContext context, ProfileLogic logic) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(logic: logic),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logic = HomeLogic(databaseService: FirebaseDatabaseService());
    final profileLogic = ProfileLogic(
      databaseService: FirebaseDatabaseService(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _button(
              isOwner ? 'Chỉnh sửa' : 'Nhắn tin',
              onPressed:
                  isOwner
                      ? () => _showEditProfileDialog(context, profileLogic)
                      : () => {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _button(
              isOwner ? 'Đăng xuất' : 'Báo cáo',
              onPressed: handleLogout,
            ),
          ),
          const SizedBox(width: 8),
          if (!isOwner)
            StreamBuilder<String>(
              stream:
                  uidFriend != null
                      ? profileLogic.getFriendStatus(uidFriend!)
                      : Stream.value('none'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final status = snapshot.data!;
                print("Dữ liệu $status");
                if (status == 'received') {
                  return Row(
                    children: [
                      _actionButton(
                        icon: Icons.check,
                        color: Colors.green,
                        tooltip: "Chấp nhận kết bạn",
                        onPressed: () async {
                          await logic.acceptFriendRequest(senderId: uidFriend!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã chấp nhận kết bạn')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.close,
                        color: Colors.red,
                        tooltip: "Từ chối lời mời",
                        onPressed: () async {
                          await logic.cancelFriendRequest(uidFriend!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã từ chối lời mời')),
                          );
                        },
                      ),
                    ],
                  );
                }

                return IconButton(
                  onPressed: () async {
                    if (status == 'none') {
                      await logic.addFriend(uidFriend!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã gửi yêu cầu kết bạn')),
                      );
                    } else if (status == 'pending') {
                      await logic.cancelFriendRequest(uidFriend!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã hủy yêu cầu kết bạn')),
                      );
                    }
                  },
                  icon: _buildFriendIcon(status),
                  tooltip:
                      status == 'pending'
                          ? 'Đã gửi yêu cầu (nhấn để hủy)'
                          : 'Kết bạn',
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _button(String title, {VoidCallback? onPressed}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black),
      ),
      onPressed: onPressed,
      child: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildFriendIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.hourglass_top, color: Colors.orange);
      case 'friend':
        return const Icon(Icons.check, color: Colors.green);
      case 'none':
      default:
        return const Icon(Icons.person_add);
    }
  }
}
