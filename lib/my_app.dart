
import 'package:android_tv/screens/home.dart';
import 'package:flutter/material.dart';

class MyApp  extends StatefulWidget {
  const MyApp ({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Android TV',
      initialRoute: '/',
      routes: {
        '/': (_) => const MediaProjectionScreen(),
      },

    );
  }
}