import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/bar_pie.dart';
import '../../models/models.dart';
import '../components/bar_chart.dart';
import '../components/common_filter.dart';
import '../components/pie_chart.dart';

/// Page for viewing Bar and Pie charts of user expenses. Selection of multiple
/// categories and Expense directions is possible. However, the expenses across
/// all directions will be summed up to generate the chart value for a category.
class BarPieChart extends StatelessWidget {
  const BarPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarPieController>(
      init: BarPieController(),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            const CommonFilter<BarPieController>(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Chart Type',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Wrap(
                  spacing: 5.0,
                  children: ChartType.values
                      .map((chartType) => ChoiceChip(
                            label: Text(chartType.toUiString()),
                            selected: _.chartType == chartType,
                            onSelected: (selected) =>
                                _.onChangeType(chartType, selected),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _.chartType == ChartType.bar
                ? const BarChartComponent()
                : const PieChartComponent(),
          ],
        ),
      ),
    );
  }
}
