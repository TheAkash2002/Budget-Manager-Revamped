import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'filter_mixin.dart';

class RelativeChangeController extends GetxController
    with FilterControllerMixin {
  List<LineSeriesData> seriesSummary = List<LineSeriesData>.empty();

  List<Expense> masterExpenses = List<Expense>.empty();
  AggregateBy aggregateBy = AggregateBy.month;

  @override
  void onInit() {
    super.onInit();
    setMonthBorderDates();
    fetchExpenseData();
  }

  void fetchExpenseData() async {
    masterExpenses = await getAllExpenses();
    List<String> categories = masterExpenses
        .map<String>((expense) => expense.category)
        .toSet()
        .toList();
    populateFilterCategoryOptions(categories);
    triggerDataChange();
  }

  @override
  void triggerDataChange() {
    seriesSummary = filterAndGenerateSeriesSummary();
    update();
  }

  //Filter functions

  @override
  void onSelectCategory(String? category, bool selected) {
    if (selected) {
      if (category == null) {
        allowedCategories = null;
      } else {
        allowedCategories ??= {};
        allowedCategories!.clear();
        allowedCategories!.add(category);
      }
    } else {
      if (allowedCategories != null) {
        allowedCategories = null;
      }
    }
    triggerDataChange();
  }

  void onSelectAggregateBy(AggregateBy e, bool value) {
    if (value == true) {
      aggregateBy = e;
      triggerDataChange();
    }
  }

  List<LineSeriesData> filterAndGenerateSeriesSummary() {
    // 1. Convert range to (monthly / daily) bins
    // 2. Map every bin to its corresponding filteredList
    // 3. Prepare sum of every filterList
    // 4. Convert this map to List<LineData>
    // 5. Write this list to DirectionMap

    masterExpenses.sort((a, b) => a.date.compareTo(b.date));
    final allowedExpenses = masterExpenses
        .where((item) =>
            allowedDirections.contains(item.direction) &&
            (allowedCategories == null ||
                allowedCategories!.contains(item.category)))
        .where((item) =>
            filterStartDate == null ||
            item.date
                .isAfter(filterStartDate!.subtract(const Duration(seconds: 5))))
        .where((item) =>
            filterEndDate == null ||
            item.date.isBefore(filterEndDate!.add(const Duration(days: 1))))
        .toList();

    Map<ExpenseDirection, List<LineData>> directionMap = {};
    DateTime? expenseStartDate, expenseEndDate;
    if (allowedExpenses.isNotEmpty) {
      expenseStartDate = DateUtils.dateOnly(allowedExpenses.first.date);
      expenseEndDate = DateUtils.dateOnly(allowedExpenses.last.date);
    }

    Iterable<DateTime> days = daysInRange(
        filterStartDate ??
            expenseStartDate ??
            DateUtils.dateOnly(DateTime.now()),
        (filterEndDate ?? expenseEndDate ?? DateUtils.dateOnly(DateTime.now()))
            .add(const Duration(days: 1)));
    Iterable<DateTime> months = monthsInRange(
        filterStartDate ??
            expenseStartDate ??
            DateUtils.dateOnly(DateTime.now()),
        (filterEndDate ?? expenseEndDate ?? DateUtils.dateOnly(DateTime.now()))
            .add(const Duration(days: 1)));

    for (ExpenseDirection direction in allowedDirections) {
      List<Expense> expenses = allowedExpenses
          .where((element) => element.direction == direction)
          .toList();
      Map<String, List<Expense>> map = {};
      if (aggregateBy == AggregateBy.day) {
        map = {
          for (var day in days)
            DateFormat.yMMMMd().format(day):
                expenses.where((e) => DateUtils.isSameDay(e.date, day)).toList()
        };
      } else {
        map = {
          for (var month in months)
            DateFormat.yMMMM().format(month): expenses
                .where((e) => DateUtils.isSameMonth(e.date, month))
                .toList()
        };
      }
      Map<String, double> sumMap = map.map((key, value) =>
          MapEntry(key, value.fold(0, (prev, e) => prev + e.amount)));
      directionMap.putIfAbsent(direction,
          () => sumMap.entries.map((e) => LineData(e.key, e.value)).toList());
    }

    List<LineSeriesData> res = directionMap.entries
        .map<LineSeriesData>(
            (e) => LineSeriesData(e.key.toExpenseDirectionUIString(), e.value))
        .toList();
    return res;
  }
}

/// Defines the data for one point corresponding to a day's or a month's bucket
/// of one particular line series (expense direction) in the line chart.
class LineData {
  String dateString;
  double expenseSum;

  LineData(this.dateString, this.expenseSum);
}

/// Defines the data for a line series corresponding to one Expense Direction
/// in the line chart.
class LineSeriesData {
  String expenseDirectionUIString;
  List<LineData> seriesData;

  LineSeriesData(this.expenseDirectionUIString, this.seriesData);
}


