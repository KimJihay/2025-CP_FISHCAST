import 'package:fishcast/features/help/help_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppbarWidget extends StatefulWidget {
  const AppbarWidget({super.key});

  @override
  State<AppbarWidget> createState() => _AppbarWidgetState();
}

class _AppbarWidgetState extends State<AppbarWidget> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = screenWidth * 0.32; // 32% of screen width
    final logoHeight = logoWidth * 0.365; // Maintain aspect ratio
    final iconSize = screenWidth < 360 ? 28.0 : 32.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          'assets/lettermark.svg',
          width: logoWidth.clamp(100.0, 140.0),
          height: logoHeight.clamp(36.0, 50.0),
        ),

        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpPage()),
            );
          },
          icon: SvgPicture.asset(
            'assets/help_icon.svg',
            width: iconSize,
            height: iconSize,
          ),
        ),
      ],
    );
  }
}
