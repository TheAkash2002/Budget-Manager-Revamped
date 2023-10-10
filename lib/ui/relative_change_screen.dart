import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../controller/relative_change_controller.dart';
import '../models/models.dart';
import '../utils/utils.dart';

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
            const Text(
              'Expense Types',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5.0,
              children: ExpenseDirection.values
                  .map((e) => FilterChip(
                      label: Text(toExpenseDirectionUIString(e)),
                      selected: _.allowedDirections.contains(e),
                      onSelected: (val) =>
                          _.onSelectExpenseDirectionChip(e, val)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Dates',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _.resetFilterStartDate,
                      ),
                      border: const OutlineInputBorder(),
                      labelText: "Start Date",
                    ),
                    child: GestureDetector(
                      onTap: () => openDatePicker(
                        context,
                        _.filterStartDate,
                        _.setFilterStartDate,
                      ),
                      child: Text(_.filterStartDate != null
                          ? DateFormat.yMMMd().format(_.filterStartDate!)
                          : ""),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: _.resetFilterEndDate,
                            icon: const Icon(Icons.close)),
                        border: const OutlineInputBorder(),
                        labelText: "End Date"),
                    child: GestureDetector(
                      onTap: () => openDatePicker(
                          context, _.filterEndDate, _.setFilterEndDate),
                      child: Text(_.filterEndDate != null
                          ? DateFormat.yMMMd().format(_.filterEndDate!)
                          : ""),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Categories',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5.0,
              children: _.categories
                  .map((e) => FilterChip(
                      label: Text(e ?? "All"),
                      selected: _.selectedCategory == e,
                      onSelected: (val) => _.onSelectCategory(e, val)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Text(
              'Aggregate By',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5.0,
              children: AggregateBy.values
                  .map((e) => ChoiceChip(
                      label: Text(toAggregateByUiString(e)),
                      selected: _.aggregateBy == e,
                      onSelected: (val) => _.onSelectAggregateBy(e, val)))
                  .toList(),
            ),
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
