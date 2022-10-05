import 'package:budget_manager_revamped/utils/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/models.dart';
import '../utils/utils.dart';

class TargetsController extends GetxController{
  late TextEditingController amountController;
  late DateTime pickerDate;

  @override
  void onInit(){
    super.onInit();
    refreshTargetsList();
  }

  TargetsController(){
    amountController = TextEditingController();
    pickerDate = DateTime.now();
  }

  void refreshInsertEditTargetControllers(){
    amountController.clear();
    pickerDate = DateTime.now();
  }

  void instantiateEditTargetControllers(Target target){
    currentTarget = target;
    amountController.text = target.amount.toString();
    setPickerDate(target.date);
  }

  List<Target> allTargets = List.empty();

  Target? currentTarget;

  Future<void> refreshTargetsList() async{
    allTargets = await getAllTargets();
    update();
  }

  void createTarget(BuildContext context) async{
    if(await isTargetSet(pickerDate)){
      showToast("Target already exists for given month and year!", context);
      return;
    }

    if(validateTargetDialog(context)){
      Target newTarget = Target(
        id: 0,
        amount: double.tryParse(amountController.text)!,
        date: getFirstDayOfMonth(pickerDate),
        lastEdit: DateTime.now(),
      );
      await insertTarget(newTarget);
      Navigator.of(context).pop(true);
      showToast("Inserted target successfully!", context);
      refreshTargetsList();
    }
  }

  void editTarget(BuildContext context) async{
    if(validateTargetDialog(context)){
      currentTarget!.amount = double.tryParse(amountController.text)!;
      currentTarget!.date = getFirstDayOfMonth(pickerDate);
      currentTarget!.lastEdit = DateTime.now();
      await updateTarget(currentTarget!);
      Navigator.of(context).pop(true);
      showToast("Updated target successfully!", context);
      refreshTargetsList();
    }
  }

  void removeTarget(int expenseId) async{
    await deleteTarget(expenseId);
    refreshTargetsList();
  }

  bool validateTargetDialog(BuildContext context){
    if(amountController.text.isEmpty || double.tryParse(amountController.text) == null){
      showToast("Enter valid amount!", context);
      return false;
    }
    return true;
  }

  void setPickerDate(DateTime dateTime) {
    pickerDate = getFirstDayOfMonth(dateTime);
    update();
  }
}