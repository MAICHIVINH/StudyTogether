import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/home/header/widget/notification.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:studytogether_v1/src/modules/home/header/widget/seach_user.dart';

class HomeHeader extends StatelessWidget {
  final String uid;
  const HomeHeader({super.key, required this.uid});

  void _showSearchInterface(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const SearchInterface();
      },
    );
  }

  void _showNotification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return NotificationSheet(uid: uid);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(
      HomeLogic(databaseService: FirebaseDatabaseService()),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Study",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("Together", style: TextStyle(fontSize: 18)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _showSearchInterface(context),
              ),
              SizedBox(width: 12),
              StreamBuilder<int>(
                stream: logic.getUnreadNotificationsCount(),
                initialData: 0,
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () => _showNotification(context),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 15,
                              minWidth: 15,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
