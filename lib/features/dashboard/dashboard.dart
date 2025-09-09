import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/cards/moon_phases_card.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/cards/weather_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String dropdownValue = "Galunggong";
  final List<String> fishTypes = [
    'Galunggong',
    'Tilapia',
    'Bangus',
    'Tuna',
    'Maya-maya',
    'Lapu-lapu',
    'Hasa-hasa',
    'Tanigue',
    'Dalagang-bukid',
    'Alumahan',
  ];

  void _onFishTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        dropdownValue = newValue;
      });
    }
  }

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
              SizedBox(height: 27),
              Text(
                "Predicty Supply Volume",
                style: TextStyle(
                  color: kForegroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Next 7d",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 83.5,
                    height: 22,
                    child: Container(
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                          color: kPrimaryStrokeColor,
                          width: 1,
                        ),
                      ),
                      child: DropdownButton<String>(
                        isDense: true,
                        isExpanded: true,
                        value: dropdownValue,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: kSecondaryTextColor,
                          size: 20,
                        ),
                        iconSize: 20,
                        elevation: 2,
                        style: const TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                        dropdownColor: Colors.white,
                        underline: const SizedBox(),
                        onChanged: _onFishTypeChanged,
                        items: fishTypes.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: LinechartWidget(pricePoints: pricePoints),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
