import 'package:flutter/material.dart';
import 'expandablegallerylist.dart';
import 'menubar.dart' as custom;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);


  //combines the menu bar and the expandable gallery list to create a home screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const custom.MenuBar(),
          Expanded(
            child: ExpandableGalleryList(),
          ),
        ],
      ),
    );
  }
}