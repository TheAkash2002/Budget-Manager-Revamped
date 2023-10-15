import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controller/bar_pie.dart';
import '../../models/models.dart';

class PieChartComponent extends StatelessWidget {
  const PieChartComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarPieController>(
      builder: (_) => SfCircularChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CircularSeries>[
          PieSeries<ChartData, String>(
            dataSource: _.summary,
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.expenseSum,
          ),
        ],
      ),
    );
  }
}
