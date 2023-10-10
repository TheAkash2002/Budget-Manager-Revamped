import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/bar_pie_controller.dart';
import '../models/models.dart';
import '../ui/bar_chart.dart';
import '../ui/pie_chart.dart';
import '../utils/utils.dart';

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
                      label: Text(e),
                      selected: _.selectedCategories.contains(e),
                      onSelected: (val) => _.onSelectCategory(e, val)))
                  .toList(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Chart Type',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...ChartType.values.map((chartType) => ListTile(
                  title: Text(toChartTypeString(chartType)),
                  leading: Radio<ChartType>(
                    value: chartType,
                    groupValue: _.chartType,
                    onChanged: _.onChangeType,
                  ),
                )),
            const SizedBox(height: 10),
            _.chartType == ChartType.bar
                ? const BarChartComponent()
                : const PieChartComponent(),
          ],
        ),
      ),
    );
  }
}
