import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:studytogether_v1/Routes/app_router.dart';
import 'package:studytogether_v1/initial_binding.dart';
import 'package:studytogether_v1/src/data/controller/post_controller.dart';
import 'package:studytogether_v1/src/data/services/firebase_realtime_service.dart';
import 'package:studytogether_v1/src/modules/Book/book_screen.dart';
import 'package:studytogether_v1/src/modules/Book/book_screen_logic.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_in/sign_in_view.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_view.dart';
import 'package:studytogether_v1/src/data/controller/user_controller.dart';
import 'package:studytogether_v1/src/modules/home/home_screen.logic.dart';
import 'package:studytogether_v1/src/modules/home/home_tab.dart';
import 'package:studytogether_v1/src/modules/home_screen.dart';
import 'package:studytogether_v1/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put(HomeLogic(databaseService: FirebaseDatabaseService()));
  Get.put(BookLogic(FirebaseDatabaseService()));
  Get.put(UserController());
  Get.put(PostController());
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  runApp(const ProviderScope(child: StudyApp()));
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "StudyTogether",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lighTheme,
      initialRoute: AppRouter.login,
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(name: AppRouter.login, page: () => SignInView()),
        GetPage(name: AppRouter.home, page: () => HomeScreen()),
        GetPage(name: AppRouter.singUp, page: () => SignUpView()),
      ],
    );
  }
}
