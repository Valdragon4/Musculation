import 'package:flutter/material.dart';
import '../navigation/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  final Widget? child;
  const MainScreen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child ?? const SizedBox.shrink(),
      bottomNavigationBar: Builder(
        builder: (context) => const BottomNavBar(),
      ),
    );
  }
} 