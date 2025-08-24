import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/appbar.dart';
import 'package:fishcast/core/widgets/cards/moon_phases_card.dart';
import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/cards/weather_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppbarWidget()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              WeatherCard(),
              SizedBox(height: 5),
              MoonPhasesCard(),
              SizedBox(height: 20),
              Text(
                "Highest Price Fish (per kg)",
                style: TextStyle(
                  color: kForegroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                ),
              ),
              SizedBox(height: 20),
              ...List.generate(5, (index) {
                final widgets = <Widget>[
                  ListTile(
                    leading: Text("${index + 1}"),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Tilapia"), Text("₱100")],
                    ),
                    trailing: Text("+3%"),
                  ),
                ];
                if (index < 4) {
                  widgets.add(const Divider());
                }
                return widgets;
              }).expand((x) => x),
              SizedBox(height: 27),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("View More"),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 27),
              Text(
                "Lowest Price Fish (per kg)",
                style: TextStyle(
                  color: kForegroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                ),
              ),
              SizedBox(height: 20),
              ...List.generate(5, (index) {
                final widgets = <Widget>[
                  ListTile(
                    leading: Text("${index + 1}"),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Tilapia"), Text("₱100")],
                    ),
                    trailing: Text("+3%"),
                  ),
                ];
                if (index < 4) {
                  widgets.add(const Divider());
                }
                return widgets;
              }).expand((x) => x),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("View More"),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
