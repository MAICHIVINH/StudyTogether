import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_logic.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_screen.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';

class SearchInterface extends StatefulWidget {
  const SearchInterface({super.key});

  @override
  State<SearchInterface> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SearchInterface> {
  final TextEditingController _searchController = TextEditingController();
  final HomeLogic logic = HomeLogic(databaseService: FirebaseDatabaseService());
  final profileLogic = ProfileLogic(databaseService: FirebaseDatabaseService());
  List<Map<String, dynamic>> _searchResults = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = await logic.searchUsersByName(query);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final filteredResults =
        results.where((user) => user['uid'] != currentUid).toList();
    // Gắn trạng thái vào từng user
    for (var user in filteredResults) {
      user['friendStatus'] =
          await profileLogic.getFriendStatus(user['uid']).first;
    }

    setState(() => _searchResults = filteredResults);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.6,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bài viết, người dùng...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                _searchResults.isEmpty
                    ? const Center(child: Text("Không có kết quả"))
                    : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: ((context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                user['photoUrl'] != null
                                    ? NetworkImage(user['photoUrl'])
                                    : null,
                            child:
                                user['photoUrl'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                          title: Text(user['name'] ?? 'No Name'),
                          subtitle: const Text('Profile'),
                          trailing: IconButton(
                            icon: _buildFriendIcon(user['friendStatus']),
                            onPressed:
                                user['friendStatus'] == 'none'
                                    ? () async {
                                      await logic.addFriend(user['uid']);
                                      setState(() {
                                        user['friendStatus'] = 'pending';
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã gửi yêu cầu kết bạn đến ${user['name'] ?? 'người dùng'}',
                                          ),
                                        ),
                                      );
                                    }
                                    : null, // Không cho bấm nếu đã gửi hoặc đã là bạn
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProfileTab(uidFriend: user['uid']),
                              ),
                            );
                          },
                        );
                      }),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendIcon(String? status) {
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
