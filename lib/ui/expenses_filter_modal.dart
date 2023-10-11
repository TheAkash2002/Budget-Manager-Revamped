import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/expense_controller.dart';
import '../ui/common_filter.dart';

class ExpensesFilterModal extends StatelessWidget {
  const ExpensesFilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            const CommonFilter<ExpenseController>(),
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
