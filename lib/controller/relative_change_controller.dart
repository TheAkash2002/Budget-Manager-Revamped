import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class RelativeChangeController extends GetxController {
  List<String?> categories = List<String>.empty();
  List<LineSeriesData> seriesSummary = List<LineSeriesData>.empty();

  List<Expense> masterExpenses = List<Expense>.empty();
  String? selectedCategory;
  Set<ExpenseDirection> allowedDirections = ExpenseDirection.values.toSet();
  DateTime? filterStartDate = getFirstDayOfMonth(DateTime.now()),
      filterEndDate = getLastDayOfMonth(DateTime.now());
  AggregateBy aggregateBy = AggregateBy.month;

  @override
  void onInit() {
    super.onInit();
    fetchExpenseData();
  }

  void fetchExpenseData() async {
    masterExpenses = await getAllExpenses();
    final List<String?> augList = [null];
    augList.addAll(
      masterExpenses.map<String>((expense) => expense.category).toSet(),
    );
    categories = augList;
    selectedCategory = null;
    getChartData();
  }

  void getChartData() {
    seriesSummary = filterAndGenerateSeriesSummary();
    update();
  }

  //Filter functions
  void onSelectExpenseDirectionChip(ExpenseDirection ed, bool selected) {
    if (selected) {
      allowedDirections.add(ed);
    } else {
      allowedDirections.remove(ed);
    }
    getChartData();
  }

  void onSelectCategory(String? category, bool selected) {
    if (selected) {
      selectedCategory = category;
    } else {
      if (category != null) {
        selectedCategory = null;
      }
    }
    getChartData();
  }

  void setFilterStartDate(DateTime? dateTime) {
    filterStartDate = dateTime;
    getChartData();
  }

  void setFilterEndDate(DateTime? dateTime) {
    filterEndDate = dateTime;
    getChartData();
  }

  void resetFilterStartDate() => setFilterStartDate(null);

  void resetFilterEndDate() => setFilterEndDate(null);

  void onSelectAggregateBy(AggregateBy e, bool value) {
    if (value == true) {
      aggregateBy = e;
      getChartData();
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
            (selectedCategory == null || selectedCategory == item.category))
        .where((item) =>
            filterStartDate == null ||
            item.date
                .isAfter(filterStartDate!.subtract(const Duration(seconds: 5))))
        .where((item) =>
            filterEndDate == null ||
            item.date.isBefore(filterEndDate!.add(const Duration(days: 1))))
        .toList();

    Map<ExpenseDirection, List<LineData>> directionMap = Map();
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
            DateFormat.yMMMd().format(day):
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
            (e) => LineSeriesData(toExpenseDirectionString(e.key), e.value))
        .toList();
    return res;
  }
}

class LineData {
  String dateString;
  double expenseSum;

  LineData(this.dateString, this.expenseSum);
}

class LineSeriesData {
  String expenseDirectionUIString;
  List<LineData> seriesData;

  LineSeriesData(this.expenseDirectionUIString, this.seriesData);
}

enum AggregateBy { month, day }

String toAggregateByUiString(AggregateBy e) =>
    e == AggregateBy.month ? "Month" : "Day";
