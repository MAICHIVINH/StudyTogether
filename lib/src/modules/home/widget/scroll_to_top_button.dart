import 'package:flutter/material.dart';

class ScrollToTopButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ScrollToTopButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 0,
      child: FloatingActionButton(
        onPressed: onPressed,
        mini: true,
        backgroundColor: Colors.blue,
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}
