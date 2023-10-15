import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import 'utils.dart';

const String expenseFileName = 'Expenses';
const String targetFileName = 'Targets';

final expenseSheetHeaders = [
  'ID',
  'Amount',
  'Category',
  'Description',
  'Direction',
  'Date',
  'Last Edited',
];

final targetSheetHeaders = [
  'ID',
  'Amount',
  'Month',
  'Last Edited',
];

void generateExcelForExpenses(List<Expense> expenses) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel[excel.getDefaultSheet()!];
  sheetObject.appendRow(expenseSheetHeaders);
  for (var expense in expenses) {
    sheetObject.appendRow(Expense.toExcelRow(expense));
  }
  await saveExcelFile(excel, expenseFileName);
}

void generateExcelForTargets(List<Target> targets) async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel[excel.getDefaultSheet()!];
  sheetObject.appendRow(targetSheetHeaders);
  for (var target in targets) {
    sheetObject.appendRow(Target.toExcelRow(target));
  }
  await saveExcelFile(excel, targetFileName);
}

Future<void> saveExcelFile(Excel excel, String filePrefix) async {
  final String fileName =
      '$filePrefix - ${DateTime.now().millisecondsSinceEpoch}.xlsx';
  if (kIsWeb) {
    excel.save(
      fileName: fileName,
    );
    return;
  }

  var fileBytes = excel.save()!;
  var directory =
      (await getDownloadsDirectory()) ?? (await getExternalStorageDirectory())!;
  var filePath = join(directory.path, fileName);
  File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes);
  showToast(ToastType.success, 'File was downloaded to $filePath');
  try {
    final Uri uri = Uri(scheme: 'content', path: filePath);
    if (!await launchUrl(uri)) {
      showToast(ToastType.error, 'Could not open file.');
    }
  } catch (e) {}
}
