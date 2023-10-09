import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/bar_pie_controller.dart';

class PieChartComponent extends StatelessWidget {
  const PieChartComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarPieController>(
      builder: (_) => AspectRatio(
        aspectRatio: 1,
        child: PieChart(PieChartData(
          borderData: FlBorderData(
            show: true,
          ),
          sections: _.summary.map(_.makePieSectionData).toList(),
        )),
      ),
    );
  }
}
