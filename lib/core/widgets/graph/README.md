# Dynamic Graph Widgets - Developer Guide

This guide explains how to use the dynamic graph widgets in the Fishcast application.

## Table of Contents
- [Overview](#overview)
- [Data Models](#data-models)
- [Configuration Classes](#configuration-classes)
- [Widget Usage](#widget-usage)
- [Examples](#examples)

---

## Overview

The graph widgets are now fully dynamic and customizable. You can:
- ✅ Connect any data source using simple lists
- ✅ Customize colors, labels, and line styles
- ✅ Configure axis ranges and intervals
- ✅ Show/hide grid, dots, and filled areas
- ✅ Use custom x-axis labels

---

## Data Models

### ChartDataPoint

The basic data structure for all charts:

```dart
ChartDataPoint(
  x: 0.0,           // X-axis value (e.g., month index, day, etc.)
  y: 25.0,          // Y-axis value (e.g., price, temperature, etc.)
  label: 'Jan',     // Optional: custom label for this point
)
```

### Creating Chart Data

**Method 1: Manual creation**
```dart
List<ChartDataPoint> myData = [
  ChartDataPoint(x: 0, y: 25),
  ChartDataPoint(x: 1, y: 30),
  ChartDataPoint(x: 2, y: 28),
];
```

**Method 2: Using helper function**
```dart
List<ChartDataPoint> myData = createChartData(
  yValues: [25, 30, 28, 35, 40],
  xValues: [0, 1, 2, 3, 4],        // Optional: defaults to index
  labels: ['A', 'B', 'C', 'D', 'E'], // Optional: custom labels
);
```

**Method 3: From existing data**
```dart
List<double> temperatures = [22.5, 23.0, 24.5, 25.0];
List<ChartDataPoint> tempData = temperatures
  .asMap()
  .map((index, value) => MapEntry(
    index, 
    ChartDataPoint(x: index.toDouble(), y: value)
  ))
  .values
  .toList();
```

---

## Configuration Classes

### LineConfig

Configures the appearance of a line in the chart:

```dart
LineConfig(
  color: Colors.blue,        // Line color
  label: 'Temperature',      // Legend label
  lineWidth: 2.0,           // Line thickness (default: 2.0)
  showDots: true,           // Show data point dots (default: true)
  showArea: true,           // Fill area under line (default: true)
  isCurved: true,           // Smooth curved line (default: true)
  areaOpacity: 0.1,         // Area transparency (default: 0.1)
)
```

**Predefined Configs:**
- `defaultPriceLineConfig` - Blue line for price data
- `defaultSupplyLineConfig` - Green line for supply data

### AxisConfig

Configures the chart axes:

```dart
AxisConfig(
  customLabels: ['Jan', 'Feb', 'Mar'],  // Custom x-axis labels
  interval: 20,                          // Y-axis interval
  minY: 0,                              // Minimum Y value
  maxY: 100,                            // Maximum Y value
  minX: 0,                              // Minimum X value
  maxX: 11,                             // Maximum X value
  showLeftTitles: true,                 // Show Y-axis labels
  showBottomTitles: true,               // Show X-axis labels
  showGrid: true,                       // Show grid lines
)
```

---

## Widget Usage

### LinechartWidget

Single line chart for displaying one data series.

**Basic Usage:**
```dart
LinechartWidget(
  data: myChartData,  // Required: List<ChartDataPoint>
)
```

**Customized Usage:**
```dart
LinechartWidget(
  data: temperatureData,
  lineConfig: LineConfig(
    color: Colors.red,
    label: 'Temperature',
    lineWidth: 3.0,
    showDots: false,
  ),
  axisConfig: AxisConfig(
    customLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    interval: 5,
    minY: 0,
    maxY: 50,
  ),
)
```

### DualLinechartWidget

Dual line chart for comparing two data series.

**Basic Usage:**
```dart
DualLinechartWidget(
  line1Data: priceData,   // Required: List<ChartDataPoint>
  line2Data: supplyData,  // Required: List<ChartDataPoint>
)
```

**Customized Usage:**
```dart
DualLinechartWidget(
  line1Data: actualData,
  line2Data: forecastData,
  line1Config: LineConfig(
    color: Colors.blue,
    label: 'Actual',
    lineWidth: 2.5,
  ),
  line2Config: LineConfig(
    color: Colors.orange,
    label: 'Forecast',
    lineWidth: 2.5,
    isCurved: false,  // Straight lines
  ),
  axisConfig: AxisConfig(
    customLabels: ['Q1', 'Q2', 'Q3', 'Q4'],
    interval: 25,
    maxY: 200,
  ),
)
```

---

## Examples

### Example 1: Temperature Chart

```dart
// Prepare data
List<double> dailyTemps = [22, 23, 25, 24, 26, 28, 27];
List<ChartDataPoint> tempData = createChartData(
  yValues: dailyTemps,
  labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
);

// Display chart
LinechartWidget(
  data: tempData,
  lineConfig: LineConfig(
    color: Colors.orange,
    label: 'Temperature (°C)',
    lineWidth: 3.0,
  ),
  axisConfig: AxisConfig(
    customLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    interval: 5,
    minY: 15,
    maxY: 35,
  ),
)
```

### Example 2: Sales vs Target Chart

```dart
// Prepare data
List<ChartDataPoint> salesData = createChartData(
  yValues: [120, 150, 180, 160, 200, 220],
);

List<ChartDataPoint> targetData = createChartData(
  yValues: [150, 150, 150, 150, 150, 150],
);

// Display chart
DualLinechartWidget(
  line1Data: salesData,
  line2Data: targetData,
  line1Config: LineConfig(
    color: Colors.green,
    label: 'Sales',
    showArea: true,
  ),
  line2Config: LineConfig(
    color: Colors.red,
    label: 'Target',
    isCurved: false,
    showArea: false,
    showDots: false,
  ),
  axisConfig: AxisConfig(
    customLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    interval: 50,
    minY: 0,
    maxY: 250,
  ),
)
```

### Example 3: Dynamic Data from API

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<ChartDataPoint> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDataFromAPI();
  }

  Future<void> loadDataFromAPI() async {
    // Fetch data from your API
    final response = await fetchMyData();
    
    setState(() {
      chartData = response.map((item) => ChartDataPoint(
        x: item.timestamp.toDouble(),
        y: item.value,
        label: item.name,
      )).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }

    return LinechartWidget(
      data: chartData,
      lineConfig: LineConfig(
        color: Colors.purple,
        label: 'API Data',
      ),
    );
  }
}
```

### Example 4: Custom Colors and Styling

```dart
// Define your custom colors
final primaryColor = Color(0xFF6200EE);
final secondaryColor = Color(0xFF03DAC6);

DualLinechartWidget(
  line1Data: data1,
  line2Data: data2,
  line1Config: LineConfig(
    color: primaryColor,
    label: 'Series 1',
    lineWidth: 3.0,
    showDots: true,
    showArea: true,
    areaOpacity: 0.2,
  ),
  line2Config: LineConfig(
    color: secondaryColor,
    label: 'Series 2',
    lineWidth: 3.0,
    showDots: true,
    showArea: true,
    areaOpacity: 0.2,
  ),
  axisConfig: AxisConfig(
    showGrid: true,
    interval: 10,
  ),
)
```

---

## Migration Guide

If you're updating existing code:

### Old Code:
```dart
LinechartWidget(pricePoints: myData)
```

### New Code:
```dart
LinechartWidget(data: myData)
```

### Old Code:
```dart
DualLinechartWidget(
  pricePoints: data1,
  supplyPoints: data2,
)
```

### New Code:
```dart
DualLinechartWidget(
  line1Data: data1,
  line2Data: data2,
)
```

**Note:** Legacy constructors are still available for backward compatibility:
```dart
LinechartWidget.legacy(pricePoints: myData)
DualLinechartWidget.legacy(pricePoints: data1, supplyPoints: data2)
```

---

## Tips and Best Practices

1. **Data Preparation**: Always ensure your data is sorted by x-values for best results
2. **Performance**: For large datasets (>100 points), consider sampling or aggregation
3. **Responsive Design**: The widgets are already responsive, no need for manual sizing
4. **Color Contrast**: Choose colors with good contrast for better readability
5. **Labels**: Keep axis labels short (3-4 characters) for better mobile display
6. **Testing**: Test with different data ranges to ensure proper scaling

---

## Troubleshooting

**Problem**: Chart appears empty
- **Solution**: Verify your data list is not empty and contains valid x/y values

**Problem**: Labels are cut off
- **Solution**: Use shorter labels or adjust the `customLabels` in `AxisConfig`

**Problem**: Y-axis range is too large/small
- **Solution**: Set explicit `minY` and `maxY` in `AxisConfig`

**Problem**: Lines don't appear smooth
- **Solution**: Set `isCurved: true` in `LineConfig`

---

## Support

For questions or issues, please refer to the main project documentation or contact the development team.
