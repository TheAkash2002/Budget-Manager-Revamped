import 'package:budget_manager_revamped/ui/insert_edit_target.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';

import '../controller/targets_controller.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class Targets extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TargetsController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text("Monthly Targets"),
          actions: [
            IconButton(
              onPressed: navigateToLoginPage,
              icon: const Icon(Icons.logout),
              tooltip: "Log Out",
            ),
          ],
        ),
        drawer: NavDrawer(),
        //body: Center(child: Text('Home: ${_.allExpenses.length}')),
        body: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: RefreshIndicator(
            onRefresh: _.refreshTargetsList,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    itemCount: _.allTargets.length,
                    itemBuilder: (context, index) => TargetItem(
                        _.allTargets[index], _.editTarget, _.removeTarget),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showCreateTargetDialog(context),
          child: const Icon(Icons.add),
          tooltip: "Create New Target",
        ),
      ),
    );
  }

  //TODO: Complete Logout Flow
  void navigateToLoginPage() {}

  void showCreateTargetDialog(BuildContext context) async {
    Get.find<TargetsController>().refreshInsertEditTargetControllers();
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
      const InsertEditTargetDialog(TargetDialogMode.insert),
    );
  }
}

class TargetItem extends StatelessWidget {
  final Target target;
  final void Function(BuildContext) editTargetController;
  final void Function(int) deleteTargetController;

  const TargetItem(
      this.target, this.editTargetController, this.deleteTargetController);

  /// Used to ensure that when any other synchronization operation or
  /// List-fetching operation is going on, any subsequent request for new
  /// synchronization/attendance/download operations are ignored.
  /*void loadingStateWrapper(void Function() intendedFn) {
    if (getLoadingState()) {
      return;
    }
    intendedFn();
  }*/

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RowWidget("Amount: ${target.amount}"),
                RowWidget("Date: ${DateFormat.yM().format(target.date)}"),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Edit Target',
                icon: const Icon(Icons.edit),
                onPressed: () => showEditTargetDialog(context),
              ),
              IconButton(
                tooltip: 'Delete Target',
                icon: const Icon(Icons.delete),
                onPressed: () => deleteTarget(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteTarget(context) async {
    bool? confirmDelete = await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Target"),
        content: const Text("Are you sure you want to delete this target? This action cannot be undone!"),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if(confirmDelete != null && confirmDelete){
      deleteTargetController(target.id);
    }
  }

  void showEditTargetDialog(BuildContext context) async {
    Get.find<TargetsController>().instantiateEditTargetControllers(target);
    await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
      const InsertEditTargetDialog(TargetDialogMode.edit),
    );
  }
}