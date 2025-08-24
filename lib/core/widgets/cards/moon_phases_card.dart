import 'package:fishcast/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MoonPhasesCard extends StatelessWidget {
  const MoonPhasesCard({super.key});

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
      height: 169.34405517578125, // Exact height as requested
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(width: 19),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pasig City, Philippines",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  Text(
                    "Aug 15, Friday",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  SizedBox(height: 45.42),
                  Text(
                    "Full Moon",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: 156,
                height: 135.34405517578125,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 112.66881561279297,
                            height: 106.09648895263672,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFDCDCDC,
                                  ).withValues(alpha: 0.43),
                                  spreadRadius: 0.8,
                                  blurRadius: 20,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/moon_phases_card/moon.svg",
                            width: 152,
                            height: 154.42,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
