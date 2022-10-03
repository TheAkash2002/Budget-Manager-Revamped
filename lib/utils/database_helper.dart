import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/models.dart';
import 'utils.dart';

const String expenseTableName = "expenses";
const String colExpenseID = "ExpenseID";
const String colExpenseAmount = "Amount";
const String colExpenseCategory = "Category";
const String colExpenseDescription = "Description";
const String colExpenseDirection = "Direction";
const String colExpenseDate = "Date";
const String colExpenseLastEdit = "LastEdit";
const String colExpenseUUID = "ExpenseUUID";

const String targetTableName = "targets";
const String colTargetID = "TargetID";
const String colTargetAmount = "Amount";
const String colTargetDate = "Date";
const String colTargetLastEdit = "LastEdit";
const String colTargetUUID = "TargetUUID";

Future<Database> getDatabase() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'budget.db');
  return openDatabase(path, onCreate: (db, version) async {
    await db.execute('CREATE TABLE $expenseTableName ('
        '$colExpenseID INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colExpenseAmount REAL NOT NULL,'
        '$colExpenseCategory TEXT NOT NULL,'
        '$colExpenseDescription TEXT NOT NULL,'
        '$colExpenseDirection TEXT NOT NULL,'
        '$colExpenseDate DATE NOT NULL,'
        '$colExpenseLastEdit DATETIME NOT NULL,'
        '$colExpenseUUID STRING)');
    await db.execute('CREATE TABLE $targetTableName ('
        '$colTargetID INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colTargetAmount REAL NOT NULL,'
        '$colTargetDate DATE NOT NULL,'
        '$colTargetLastEdit DATETIME NOT NULL,'
        '$colTargetUUID STRING)');
  }, version: 1);
}

Future<void> updateCategory(String oldCategory, String newCategory) async {
  final List<Map<String, dynamic>> maps = await (await getDatabase()).query(
    expenseTableName,
    where: '$colExpenseCategory = ?',
    whereArgs: [oldCategory],
  );
  List<Expense> updatedExpenses =
      List.generate(maps.length, (index) => Expense.fromMap(maps[index]));
  for (Expense expense in updatedExpenses) {
    expense.category = newCategory;
    updateExpense(expense);
  }
}

Future<void> insertTarget(Target target) async {
  await (await getDatabase()).insert(
    targetTableName,
    target.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<bool> isTargetSet(DateTime dateTime) async {
  return await getTarget(dateTime) != -1;
}

Future<double> getTarget(DateTime dateTime) async {
  final List<Map<String, dynamic>> targetMaps =
      await (await getDatabase()).query(
    targetTableName,
    where: '$colTargetDate = ?',
    whereArgs: [getFirstDayOfMonth(dateTime).toIso8601String()],
  );
  return targetMaps.isEmpty ? -1 : Target.fromMap(targetMaps[0]).amount;
}

Future<List<Target>> getAllTargets() async {
  final List<Map<String, dynamic>> maps =
      await (await getDatabase()).query(targetTableName);
  return List.generate(maps.length, (i) {
    return Target.fromMap(maps[i]);
  });
}

Future<void> updateTarget(Target target) async {
  await (await getDatabase()).update(
    targetTableName,
    target.toMap(),
    where: '$colTargetID = ?',
    whereArgs: [target.id],
  );
}

Future<void> deleteTarget(int id) async {
  await (await getDatabase()).delete(
    targetTableName,
    where: '$colTargetID = ?',
    whereArgs: [id],
  );
}

Future<void> insertExpense(Expense expense) async {
  await (await getDatabase()).insert(
    expenseTableName,
    expense.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Expense>> getAllExpenses() async {
  final List<Map<String, dynamic>> maps =
      await (await getDatabase()).query(expenseTableName);
  return List.generate(maps.length, (i) {
    return Expense.fromMap(maps[i]);
  });
}

Future<List<Expense>> getAllExpensesInGivenMonth(DateTime dateTime) async {
  String firstDay = getFirstDayOfMonth(dateTime).toIso8601String();
  String lastDay = getLastDayOfMonth(dateTime).toIso8601String();
  final List<Map<String, dynamic>> maps = await (await getDatabase()).query(
    expenseTableName,
    where: "$colExpenseDate BETWEEN ? AND ?",
    whereArgs: [firstDay, lastDay],
  );
  return List.generate(maps.length, (i) {
    return Expense.fromMap(maps[i]);
  });
}

Future<void> updateExpense(Expense expense) async {
  await (await getDatabase()).update(
    expenseTableName,
    expense.toMap(),
    where: '$colExpenseID = ?',
    whereArgs: [expense.id],
  );
}

Future<void> deleteExpense(int id) async {
  await (await getDatabase()).delete(
    expenseTableName,
    where: '$colExpenseID = ?',
    whereArgs: [id],
  );
}

Future<List<String>> getExistingCategoriesList() async {
  final List<Map<String, dynamic>> maps = await (await getDatabase())
      .rawQuery("SELECT DISTINCT $colExpenseCategory FROM $expenseTableName");
  return List.generate(maps.length, (index) => maps[index][colExpenseCategory]);
}
