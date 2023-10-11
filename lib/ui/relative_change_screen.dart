import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../controller/relative_change_controller.dart';
import 'common_filter.dart';

class RelativeChange extends StatelessWidget {
  const RelativeChange({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RelativeChangeController>(
      init: RelativeChangeController(),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const CommonFilter<RelativeChangeController>(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Aggregate By',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Wrap(
                  spacing: 5.0,
                  children: AggregateBy.values
                      .map((e) => ChoiceChip(
                          label: Text(e.toUiString()),
                          selected: _.aggregateBy == e,
                          onSelected: (val) => _.onSelectAggregateBy(e, val)))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SfCartesianChart(
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              series: _.seriesSummary
                  .map<ChartSeries>((summary) =>
                      StackedLine100Series<LineData, String>(
                          name: summary.expenseDirectionUIString,
                          legendItemText: summary.expenseDirectionUIString,
                          dataSource: summary.seriesData,
                          xValueMapper: (LineData data, _) => data.dateString,
                          yValueMapper: (LineData data, _) => data.expenseSum))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
