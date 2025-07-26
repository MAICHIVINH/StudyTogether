import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studytogether_v1/Routes/app_router.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';
import 'package:studytogether_v1/src/modules/create_post/create_post_screen.dart';
import 'package:studytogether_v1/src/modules/home/header/home_header.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:studytogether_v1/src/modules/home/post/home_post_item.dart';
import 'package:studytogether_v1/src/modules/home/widget/bottom_nav_bar.dart';
import 'package:studytogether_v1/src/modules/home/widget/post_feed_list.dart';
import 'package:studytogether_v1/src/modules/home/widget/scroll_to_top_button.dart';
import 'package:studytogether_v1/src/modules/home/widget/user_stories_list.dart';
import 'package:studytogether_v1/src/modules/user_story/home_userStory.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        if (!_showScrollToTopButton) {
          setState(() => _showScrollToTopButton = true);
        }
      } else {
        if (_showScrollToTopButton) {
          setState(() => _showScrollToTopButton = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    final homeLogic = HomeLogic(databaseService: FirebaseDatabaseService());
    final UserController userController = Get.find<UserController>();
    final imageUrl =
        userController.photoUrl.toString() ?? "assets/images/avatar.png";
    final username = userController.name.toString() ?? "Your story";
    final uidUser = userController.uid.toString();

    // final users = [
    //   {"image": "assets/images/avatar.png", "name": "Your story"},
    //   {"image": "assets/images/user1.jpg", "name": "jaded.ele..."},
    //   {"image": "assets/images/user2.jpg", "name": "pia.in.a.pod"},
    //   {"image": "assets/images/user3.jpg", "name": "lil.wyatt..."},
    //   {"image": "assets/images/user4.jpg", "name": "lil.wyatt..."},
    //   {"image": "assets/images/user4.jpg", "name": "lil.wyatt..."},
    //   {"image": "assets/images/user4.jpg", "name": "lil.wyatt..."},
    //   {"image": "assets/images/user4.jpg", "name": "lil.wyatt..."},
    // ];

    void onItemTapped(int index) {
      if (index == 3) {
        Get.offNamed(AppRouter.login);
      } else {
        setState(() {
          selectedIndex = index;
        });
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // feat(ui): create HomeScreen layout with header, stories, and post feed
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: HomeHeader(uid: uidUser),
              ),
              //feat(ui): add ScrollToTopButton when scroll offset exceeds 300
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    homeLogic.fetchPostData(uidUser);
                  },
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _scrollController,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      children: [
                        // UserStoriesList(users: users),
                        SizedBox(height: 10),
                        Obx(() {
                          final imageUrl =
                              userController.photoUrl.value.isNotEmpty
                                  ? userController.photoUrl.value
                                  : "assets/images/avatar.png";

                          final username =
                              userController.name.value.isNotEmpty
                                  ? userController.name.value
                                  : "Your story";
                          // feat(logic): bind user avatar and username from UserController using GetX
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      imageUrl.startsWith('http')
                                          ? NetworkImage(imageUrl)
                                          : AssetImage(imageUrl)
                                              as ImageProvider,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => CreatePostScreen(
                                                imageUrl: imageUrl,
                                                username: username,
                                                uid: userController.uid.value,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Bạn có bài viết gì không",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // feat(logic): bind user avatar and username from UserController using GetX
                        PostFeedList(uid: uidUser),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_showScrollToTopButton)
            ScrollToTopButton(onPressed: _scrollToTop),
        ],
      ),
    );
  }
}
