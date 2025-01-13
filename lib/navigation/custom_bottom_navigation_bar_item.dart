import 'package:flutter/material.dart';

class CustomBottomNavigationBarItem extends BottomNavigationBarItem {
  
  // constructor
  CustomBottomNavigationBarItem({
    required String assetPath,
    Color inactiveColor = Colors.grey,
    Color activeColor = const Color(0xFF007167),
    double inactiveWidth = 30.0,
    double inactiveHeight = 30.0,
    double activeWidth = 35.0,
    double activeHeight = 35.0,
    String label = '',
  }) : super( // calling the constructor in the parent class
          icon: Image.asset(
            assetPath,
            color: inactiveColor,
            width: inactiveWidth,
            height: inactiveHeight,
          ),
          activeIcon: Image.asset(
            assetPath,
            color: activeColor,
            width: activeWidth,
            height: activeHeight,
          ),
          label: label,
    );
}