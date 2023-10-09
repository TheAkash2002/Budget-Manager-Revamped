import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class BarPieController extends GetxController {
  ChartType chartType = ChartType.bar;
  List<String> categories = List<String>.empty();
  List<ChartData> summary = List<ChartData>.empty();

  @override
  void onInit() {
    super.onInit();
    fetchExpenseData();
  }

  void fetchExpenseData() async {
    masterExpenses = await getAllExpenses();
    categories = masterExpenses
        .map<String>((expense) => expense.category)
        .toSet()
        .toList();
    selectedCategories = categories.toSet();
    getChartData();
  }

  void onChangeType(ChartType? newType) {
    if (newType != null) {
      chartType = newType;
      update();
    }
  }

  void getChartData() {
    summary = filterList();
    update();
  }

  BarChartGroupData makeBarGroupData(ChartData data) {
    int index = summary.indexOf(data);
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: data.expenseSum,
          color: Theme.of(Get.context!).colorScheme.primary,
          width: 22,
        ),
      ],
    );
  }

  PieChartSectionData makePieSectionData(ChartData data) => PieChartSectionData(
        color: Theme.of(Get.context!).colorScheme.primary,
        value: data.expenseSum,
        radius: 100,
        title: "${data.category}\n${data.expenseSum}",
      );

  Widget getCategoryTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(
        categories[index],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  //Filter functions
  List<Expense> masterExpenses = List<Expense>.empty();
  Set<String> selectedCategories = {};
  Set<ExpenseDirection> allowedDirections = ExpenseDirection.values.toSet();
  DateTime? filterStartDate = getFirstDayOfMonth(DateTime.now()),
      filterEndDate = getLastDayOfMonth(DateTime.now());

  void onSelectExpenseDirectionChip(ExpenseDirection ed, bool selected) {
    if (selected) {
      allowedDirections.add(ed);
    } else {
      allowedDirections.remove(ed);
    }
    getChartData();
  }

  void onSelectCategory(String category, bool selected) {
    if (selected) {
      selectedCategories.add(category);
    } else {
      selectedCategories.remove(category);
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

  List<ChartData> filterList() {
    final allowedExpenses = masterExpenses
        .where((item) =>
            allowedDirections.contains(item.direction) &&
            selectedCategories.contains(item.category))
        .where((item) =>
            filterStartDate == null || item.date.isAfter(filterStartDate!))
        .where((item) =>
            filterEndDate == null ||
            item.date.isBefore(filterEndDate!.add(const Duration(days: 1))));

    Map<String, double> sumMap =
        groupBy<Expense, String>(allowedExpenses, (expense) => expense.category)
            .map(
      (key, value) => MapEntry(
        key,
        value.fold(
          0,
          (previousValue, element) => previousValue + element.amount,
        ),
      ),
    );
    return sumMap.entries.map((e) => ChartData(e.key, e.value)).toList();
  }
}

enum ChartType { bar, pie }

String toChartTypeString(ChartType type) {
  return type == ChartType.bar ? "Bar" : "Pie";
}

enum ChartExpenseTypeChoice { payment, loan_credit, loan_debit, overall }

class ChartData {
  String category;
  double expenseSum;

  ChartData(this.category, this.expenseSum);
}
