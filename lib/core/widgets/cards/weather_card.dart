import 'package:fishcast/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF03457F), Color(0xFF009BDD)],
        ),
      ),
      height: 169.34405517578125, // Exact height as requested
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 156,
                height: 135.34405517578125,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 14.68,
                      left: 39.84,
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
                                    0xFFFFEE9A,
                                  ).withValues(alpha: 0.8),
                                  spreadRadius: 0.8,
                                  blurRadius: 20,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          // Original SVG Sun
                          SvgPicture.asset(
                            "assets/weather_card/sun.svg",
                            width: 87.64631652832031,
                            height: 87.64631652832031,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 58.48,
                      left: 19,
                      child: SvgPicture.asset(
                        "assets/weather_card/clouds.svg",
                        width: 122.86,
                        height: 68.87,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Zamboanga City, Philippines",
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
                  Text(
                    "25°",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  Text(
                    "77 Fahrenheit",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),
              SizedBox(width: 19),
            ],
          ),
        ],
      ),
    );
  }
}
