import 'package:flutter/material.dart';
import 'core/theme/scaffold/customer_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devdara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        fontFamily: 'Roboto',
      ),
      home: const BasePage(),
    );
  }
}