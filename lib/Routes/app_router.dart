import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/modules/Book/book_screen.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_in/sign_in_view.dart';
import 'package:studytogether_v1/src/modules/authentication/sign_up/sign_up_view.dart';
import 'package:studytogether_v1/src/modules/home/home_tab.dart';
import 'package:studytogether_v1/src/modules/home_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String singUp = '/signUp';
  static const String book = "/book";
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomeScreen(),
    login: (context) => SignInView(),
    singUp: (context) => SignUpView(),
    book: (context) => BookTab(),
  };
}
