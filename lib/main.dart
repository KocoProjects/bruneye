import 'package:bruneye/theme/themebsi.dart';
import 'package:flutter/material.dart';
import 'ui/splash/splashstart.dart';
import 'ui/homescreen/homescreen.dart';

// main access point of the Bruneye
void main() {
  runApp(MyApp());
}

// Root of the Bruneye
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       // Set the app theme
      theme: artEducationTheme,
      // Display the splash screen at the start
      home: SplashStart(
        nextScreen: const HomeScreen(),
        duration: 2,
        //splash is visible for two seconds and then to the home screen
      ),
    );
  }
}
