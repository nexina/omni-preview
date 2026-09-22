import 'package:flutter/material.dart';
import 'dart:ui';

class BackgroundBuilder extends StatelessWidget {
  final Widget child;
  const BackgroundBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔒 Always painted first — no white frame
          const ColoredBox(color: Colors.black),

          // Background image
          const Image(
            image: AssetImage("assets/images/default.jpg"),
            fit: BoxFit.cover,
          ),

          // Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),

          // Dark overlay + content
          SafeArea(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
