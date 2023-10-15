import 'package:get/get.dart';

import '../models/models.dart';
import '../utils/utils.dart';

/// Provides functionality to use a filter on an Expenses list based on dates,
/// expense direction and category. Any controller implementing this can expose
/// getters and setters for UI elements utilizing these common filters.
mixin FilterControllerMixin on GetxController {
  /// Expense Directions allowed by the filter.
  Set<ExpenseDirection> allowedDirections = ExpenseDirection.values.toSet();

  /// Categories allowed by the filter. If this is `null`, it represents that
  /// all categories are selected.
  Set<String>? allowedCategories;

  /// Options for categories shown in the UI. `null` represents option of 'All'.
  List<String?> filterCategoryOptions = List<String?>.empty();

  /// Start date for the expenses allowed by the filter.
  DateTime? filterStartDate;

  /// End date for the expenses allowed by the filter.
  DateTime? filterEndDate;

  /// Handler for selection of a category. If a category is selected,
  /// nullify `allowedCategories` if `null` was tapped, otherwise add the tapped
  /// category to `allowedCategories`. If a category is removed, take action and
  /// remove `category` from `allowedCategories` if the category is not `null`
  /// (selection of 'All').
  void onSelectCategory(String? category, bool selected) {
    if (selected) {
      if (category == null) {
        allowedCategories = null;
      } else {
        allowedCategories ??= <String>{};
        allowedCategories?.add(category);
      }
    } else {
      if (category != null) {
        allowedCategories?.remove(category);
      }
    }
    triggerDataChange();
  }

  /// Handler for selection of ExpenseDirection.
  void onSelectExpenseDirectionChip(ExpenseDirection ed, bool selected) {
    if (selected) {
      allowedDirections.add(ed);
    } else {
      allowedDirections.remove(ed);
    }
    triggerDataChange();
  }

  void setFilterStartDate(DateTime? dateTime) {
    filterStartDate = dateTime;
    triggerDataChange();
  }

  void setFilterEndDate(DateTime? dateTime) {
    filterEndDate = dateTime;
    triggerDataChange();
  }

  void resetFilterStartDate() => setFilterStartDate(null);

  void resetFilterEndDate() => setFilterEndDate(null);

  /// Defines the UI update action to be taken whenever a filter property is
  /// changed. Controllers must implement this to define what & how data should
  /// be recalculated in the event of change in filter properties like
  /// `filterStartDate`, `filterEndDate`, `allowedCategories`, `allowedDirections`.
  void triggerDataChange();

  /// Prepend `null` to `allCategories` for showing the list of categories in
  /// the UI and provide an option for 'All'.
  void populateFilterCategoryOptions(List<String> allCategories) {
    final List<String?> augList = [null];
    augList.addAll(allCategories.toSet());
    filterCategoryOptions = augList;
  }

  /// Sets default values for `filterStartDate` and `filterEndDate` for
  /// controllers related to summarizing data.
  void setMonthBorderDates() {
    filterStartDate = getFirstDayOfMonth(DateTime.now());
    filterEndDate = getLastDayOfMonth(DateTime.now());
  }
}
