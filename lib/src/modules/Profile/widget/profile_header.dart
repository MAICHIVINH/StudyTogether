import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_logic.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final logic = ProfileLogic(databaseService: FirebaseDatabaseService());
    final homeLogic = HomeLogic(databaseService: FirebaseDatabaseService());

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user["uid"] != currentUid)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  () => {
                    Navigator.pop(context),
                    homeLogic.fetchPostData(currentUid ?? user["uid"]),
                  },
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage:
                    user['photoUrl'] != null
                        ? NetworkImage(user['photoUrl'])
                        : null,
                child:
                    user['photoUrl'] == null
                        ? const Icon(Icons.person, size: 35)
                        : null,
              ),

              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['email'] ?? 'Không có email',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(user['name'] ?? 'Không có tên'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder(
                          future: logic.countPostsByUid(
                            user["uid"] ?? "084UoRoBzDRMsWCpJYsTsa9teD32",
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildStat('bài viết', '...');
                            } else if (snapshot.hasError) {
                              return _buildStat('bài viết', '0');
                            } else {
                              return _buildStat(
                                'bài viết',
                                snapshot.data.toString(),
                              );
                            }
                          },
                        ),
                        StreamBuilder(
                          stream: logic.getFriendCountStream(
                            user["uid"] ?? "084UoRoBzDRMsWCpJYsTsa9teD32",
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildStat('bạn bè', '...');
                            } else if (snapshot.hasError) {
                              return _buildStat('bạn bè', '0');
                            } else {
                              return _buildStat(
                                'bạn bè',
                                snapshot.data.toString(),
                              );
                            }
                          },
                        ),
                        StreamBuilder(
                          stream: logic.getFriendRequestCountStream(
                            user["uid"] ?? "084UoRoBzDRMsWCpJYsTsa9teD32",
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildStat('đang theo dõi', '...');
                            } else if (snapshot.hasError) {
                              print("Lỗi ❌: ${snapshot.error}");
                              return _buildStat('đang theo dõi', '0');
                            } else {
                              return _buildStat(
                                'đang theo dõi',
                                snapshot.data.toString(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
