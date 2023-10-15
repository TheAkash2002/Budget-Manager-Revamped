import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../db/firestore_helper.dart';
import '../models/models.dart';
import 'filter_mixin.dart';

/// Controller for BarPieChart page.
class BarPieController extends GetxController with FilterControllerMixin {
  ChartType chartType = ChartType.bar;
  List<ChartData> summary = List<ChartData>.empty();

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

  void onChangeType(ChartType newType, bool selected) {
    if (selected == true) {
      chartType = newType;
      update();
    }
  }

  @override
  void triggerDataChange() {
    summary = filterList();
    update();
  }

  //Filter functions
  List<Expense> masterExpenses = List<Expense>.empty();

  List<ChartData> filterList() {
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


