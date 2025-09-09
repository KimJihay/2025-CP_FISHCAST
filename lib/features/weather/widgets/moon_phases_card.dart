import 'package:flutter/material.dart';

class MoonPhases extends StatelessWidget {
  const MoonPhases({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF41565F)],
        ),
      ),
      height: 469, // Exact height as requested
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text("Hello World")],
      ),
    );
  }
}
