import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/expense_controller.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class ListFilter extends StatelessWidget {
  const ListFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
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
            const SizedBox(height: 15.0),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 5.0,
              children: _.filterCategoryOptions
                  .map((e) => FilterChip(
                      label: Text(e ?? "All"),
                      selected: (e == null && _.allowedCategories == null) ||
                          (_.allowedCategories?.contains(e) ?? false),
                      onSelected: (val) => _.onSelectCategory(e, val)))
                  .toList(),
            ),
            const SizedBox(height: 15.0),
            const Text(
              'Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18.0),
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
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: _.onApplyClick, child: const Text("Apply"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
