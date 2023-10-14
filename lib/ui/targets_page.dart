import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/targets_controller.dart';
import '../models/models.dart';
import '../ui/insert_edit_target_dialog.dart';
import 'custom_components.dart';
import 'delete_target_dialog.dart';

class Targets extends StatelessWidget {
  const Targets({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TargetsController>(
      init: TargetsController(),
      builder: (_) => StreamBuilder<List<Target>>(
          stream: _.targetStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Some error occurred."));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("No data!"));
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                      "No targets found. Add a target to see its details here."));
            }
            double width = double.maxFinite;
            if (MediaQuery.of(context).orientation == Orientation.landscape) {
              width = MediaQuery.of(context).size.width * 0.7;
            }
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                width: width,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) =>
                      TargetItem(snapshot.data![index], _.removeTarget),
                ),
              ),
            );
          }),
    );
  }
}

class TargetItem extends StatelessWidget {
  final Target target;
  final void Function(String) deleteTargetController;

  const TargetItem(this.target, this.deleteTargetController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RowWidget(
                    "₹${target.amount}",
                    isHeader: true,
                  ),
                  RowWidget(
                    DateFormat.yMMMM().format(target.date),
                    icon: const Icon(Icons.calendar_month_sharp),
                  ),
                ],
              ),
            ),
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResizableIconButton(
                    tooltip: 'Edit Target',
                    icon: const Icon(Icons.edit),
                    onPressed: showEditTargetDialog,
                  ),
                  ResizableIconButton(
                    tooltip: 'Delete Target',
                    icon: const Icon(Icons.delete),
                    onPressed: deleteTarget,
                  ),
                ],
              ),
            ),
          ],
        ),
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
