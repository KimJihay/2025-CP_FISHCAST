import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:fishcast/core/widgets/graph/dual_linechart_widget.dart';
import 'package:fishcast/core/services/fish_type_service.dart';
import 'package:flutter/material.dart';

class ForecastPage extends StatefulWidget {
  const ForecastPage({super.key});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  final FishTypeService _fishTypeService = FishTypeService();
  
  List<String> fishTypes = [];
  bool _isLoadingFishTypes = true;
  String dropdownValue = "Galunggong";

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
  }

  /// Load fish types from API or use defaults
  Future<void> _loadFishTypes() async {
    try {
      final types = await _fishTypeService.getFishTypeNames();
      
      if (mounted) {
        setState(() {
          fishTypes = types;
          _isLoadingFishTypes = false;
          // Ensure dropdownValue is valid
          if (!fishTypes.contains(dropdownValue) && fishTypes.isNotEmpty) {
            dropdownValue = fishTypes.first;
          }
        });
      }
    } catch (e) {
      // Fallback to default fish types
      if (mounted) {
        setState(() {
          fishTypes = _fishTypeService.getDefaultFishTypeNames();
          _isLoadingFishTypes = false;
          if (!fishTypes.contains(dropdownValue) && fishTypes.isNotEmpty) {
            dropdownValue = fishTypes.first;
          }
        });
      }
    }
  }

  void _onFishTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        dropdownValue = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFishTypes) {
      return Scaffold(
        appBar: AppBar(title: const AppbarWidget()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const AppbarWidget()),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final chartHeight = screenHeight * 0.25; // 25% of screen height

            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: MediaQuery.of(context).padding.top + 16,
              ),
              children: [
                Row(
                  children: [
                    Text(
                      "Market Forecast",
                      style: TextStyle(
                        color: kForegroundColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Price and Supply",
                  style: TextStyle(
                    color: kForegroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 4),
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
                const SizedBox(height: 14),
                Container(
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxHeight: chartHeight.clamp(200, 400),
                  ),
                  width: double.infinity,
                  child: DualLinechartWidget(
                    line1Data: pricePoints,
                    line2Data: supplyPoints,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Fish by Price",
                  style: TextStyle(
                    color: kForegroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                  ),
                ),
                SizedBox(height: 16),
                ...List.generate(5, (index) {
                  final widgets = <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tilapia",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "₱100",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "+3%",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                  if (index < 4) {
                    widgets.add(
                      const Divider(height: 1, indent: 16, endIndent: 16),
                    );
                  }
                  return widgets;
                }).expand((x) => x),
              ],
            );
          },
        ),
      ),
    );
  }
}
