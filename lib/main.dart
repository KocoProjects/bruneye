import 'theme/themepurps.dart';
import 'package:flutter/material.dart';
import 'gallery/galleryslide/gallerysilder.dart';
import 'homescreen/expandablegallerylist.dart';
import 'splash/splashstart.dart';
import 'homescreen/menubar.dart' as custom;
import 'homescreen/homescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: myTheme,
      home: SplashStart(
        nextScreen: const HomeScreen(),
        duration: 2,
      ),
    );
  }
}
