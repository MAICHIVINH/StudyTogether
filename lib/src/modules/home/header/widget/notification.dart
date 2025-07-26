import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_screen.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';

class NotificationSheet extends StatefulWidget {
  final String uid;
  const NotificationSheet({super.key, required this.uid});

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  final HomeLogic logic = HomeLogic(databaseService: FirebaseDatabaseService());

  String _formatTime(dynamic milliseconds) {
    if (milliseconds is int) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    return '';
  }

  @override
  void dispose() {
    logic.updateIsReadNotification(widget.uid);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 2 / 3,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Thông báo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: logic.listenToNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notifications = snapshot.data ?? [];

                  if (notifications.isEmpty) {
                    return const Center(child: Text("Không có thông báo nào."));
                  }

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      print("dữ liệu $n");
                      return ListTile(
                        onTap:
                            () => {
                              if (n['type'] == 'friend_request')
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProfileTab(
                                            uidFriend: n['fromUid'],
                                          ),
                                    ),
                                  ),
                                },
                            },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(n['fromAvatar'] ?? ''),
                        ),
                        title: Text(n['message'] ?? ''),
                        subtitle: Text(_formatTime(n['createdAt'])),
                        trailing:
                            n['isRead'] == true
                                ? null
                                : const Icon(
                                  Icons.circle,
                                  color: Colors.blue,
                                  size: 10,
                                ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
