import 'package:get/get.dart';

import '../models/models.dart';

mixin FilterControllerMixin on GetxController {
  Set<ExpenseDirection> allowedDirections = ExpenseDirection.values.toSet();
  Set<String>? allowedCategories;
  List<String?> filterCategoryOptions = List<String?>.empty();
  DateTime? filterStartDate, filterEndDate;

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

  void triggerDataChange();

  void populateFilterCategoryOptions(List<String> allCategories){
    final List<String?> augList = [null];
    augList.addAll(allCategories.toSet());
    filterCategoryOptions = augList;
  }
}
