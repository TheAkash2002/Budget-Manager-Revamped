import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/targets_controller.dart';
import '../models/models.dart';
import '../ui/insert_edit_target_dialog.dart';
import '../utils/utils.dart';
import 'delete_target_dialog.dart';

class Targets extends StatelessWidget {
  const Targets({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TargetsController>(
      builder: (_) => StreamBuilder<List<Target>>(
          stream: _.targetStream,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              print("Error!");
              print(snapshot.error);
              return const Text("Error");
            }
            if (!snapshot.hasData) {
              print("No data!");
              return const Text("No data!");
            }
            return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: RefreshIndicator(
                onRefresh: _.refreshTargetStreamReference,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => TargetItem(
                            snapshot.data![index],
                            _.editTarget,
                            _.removeTarget),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class TargetItem extends StatelessWidget {
  final Target target;
  final void Function(BuildContext) editTargetController;
  final void Function(String) deleteTargetController;

  const TargetItem(
      this.target, this.editTargetController, this.deleteTargetController,
      {super.key});

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
                onPressed: showEditTargetDialog,
              ),
              IconButton(
                tooltip: 'Delete Target',
                icon: const Icon(Icons.delete),
                onPressed: deleteTarget,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteTarget() async {
    bool? confirmDelete = await showDialog<bool?>(
      context: Get.context!,
      barrierDismissible: false, // user must tap button!
      builder: (ctx) => const DeleteTargetDialog(),
    );

    if (confirmDelete != null && confirmDelete) {
      deleteTargetController(target.id);
    }
  }

  void showEditTargetDialog() {
    Get.find<TargetsController>().instantiateEditTargetControllers(target);
    showDialog<bool?>(
      context: Get.context!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) =>
          const InsertEditTargetDialog(TargetDialogMode.edit),
    );
  }
}
