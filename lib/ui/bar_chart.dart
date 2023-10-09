import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/bar_pie_controller.dart';

class BarChartComponent extends StatelessWidget {
  const BarChartComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarPieController>(
      builder: (_) => AspectRatio(
        aspectRatio: 1,
        child: BarChart(BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              tooltipHorizontalAlignment: FLHorizontalAlignment.right,
              tooltipMargin: -10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                ChartData data = _.summary[group.x];
                return BarTooltipItem(
                  '${data.category}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rod.toY).toString(),
                      style: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _.getCategoryTitles,
                reservedSize: 38,
              ))),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: _.summary.map(_.makeBarGroupData).toList(),
          gridData: const FlGridData(
            show: false,
          ),
        )),
      ),
    );
  }
}
