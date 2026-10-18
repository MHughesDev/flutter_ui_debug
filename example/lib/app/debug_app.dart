import 'package:flutter/material.dart';
import 'demo_home_page.dart';

class DebugDemoApp extends StatelessWidget {
  const DebugDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Debug Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
