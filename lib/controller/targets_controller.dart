import 'package:budget_manager_revamped/utils/database_helper.dart';
import 'package:get/get.dart';

import '../models/models.dart';

class TargetsController extends GetxController{
  List<Target> allTargets = List.empty();

  Expense? currentTarget;

  void refreshTargetsList() async{
    allTargets = await getAllTargets();
  }

}