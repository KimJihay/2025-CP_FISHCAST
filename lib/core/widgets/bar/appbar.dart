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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SvgPicture.asset(
          'assets/lettermark.svg',
          width: 123.10906982421875,
          height: 45.00166702270508,
        ),

        IconButton(
          onPressed: () {
            //TODO: Open Help Page
          },
          icon: SvgPicture.asset('assets/help_icon.svg', width: 32, height: 32),
        ),
      ],
    );
  }
}
