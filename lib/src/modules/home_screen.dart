import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Book/book_screen.dart';
import 'package:studytogether_v1/src/modules/Profile/profile_screen.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:studytogether_v1/src/modules/home/home_tab.dart';
import 'package:studytogether_v1/src/modules/home/widget/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final HomeLogic homeLogic;
  late final UserController userController;

  final List<Widget> _screens = [
    const HomeTab(),
    const BookTab(),
    const ProfileTab(uidFriend: null),
  ];

  @override
  void initState() {
    super.initState();
    homeLogic = Get.put(HomeLogic(databaseService: FirebaseDatabaseService()));
    userController = Get.find<UserController>();
    if (_selectedIndex == 0) {
      homeLogic.fetchPostData(userController.uid.value);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0 && userController.uid.value.isNotEmpty) {
        homeLogic.fetchPostData(userController.uid.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
