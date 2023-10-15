import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controller/bar_pie.dart';
import '../../models/models.dart';

/// Bar chart for BarPieChart page.
class BarChartComponent extends StatelessWidget {
  const BarChartComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarPieController>(
      builder: (_) => SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<ChartData, String>>[
            BarSeries<ChartData, String>(
              dataSource: _.summary,
              xValueMapper: (data, _) => data.category,
              yValueMapper: (data, _) => data.expenseSum,
              name: 'Money',
            ),
          ]),
    );
  }
}
