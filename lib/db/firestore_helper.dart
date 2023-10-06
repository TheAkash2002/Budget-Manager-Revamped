import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import '../utils/utils.dart';

const masterCollectionName = "V1";
const String expenseTableName = "expenses";
const String targetTableName = "targets";

DocumentReference getDatabase() {
  String? email = FirebaseAuth.instance.currentUser?.email;
  if (email == null) {
    throw Exception("Not logged in");
  }
  return FirebaseFirestore.instance.collection(masterCollectionName).doc(email);
}

CollectionReference<Expense> getExpenseTable() {
  return getDatabase().collection(expenseTableName).withConverter(
      fromFirestore: Expense.fromMap,
      toFirestore: (expense, _) => Expense.toMap(expense));
}

CollectionReference<Target> getTargetTable() {
  return getDatabase().collection(targetTableName).withConverter(
      fromFirestore: Target.fromMap,
      toFirestore: (target, _) => Target.toMap(target));
}

Future<void> updateCategory(String oldCategory, String newCategory) async {
  try {
    final newExpenses = (await getAllExpenses())
        .where((element) => element.category == oldCategory)
        .map<Expense>((old) {
      old.category = newCategory;
      return old;
    }).toList();
    for (Expense e in newExpenses) {
      await (getExpenseTable()).doc(e.id).update(Expense.toMap(e));
    }
  } catch (e) {}
}

Future<void> insertTarget(Target target) async {
  try {
    await getTargetTable().add(target);
  } catch (e) {}
}

Future<bool> isTargetSet(DateTime dateTime) async {
  return await getTarget(dateTime) != -1;
}

Future<double> getTarget(DateTime dateTime) async {
  try {
    final docs = (await getTargetTable()
            .where(colTargetDate,
                isEqualTo: getFirstDayOfMonth(dateTime).toIso8601String())
            .get())
        .docs;
    return docs.isEmpty ? -1 : docs[0].data().amount;
  } catch (e) {}
  return -1;
}

Future<List<Target>> getAllTargets() async {
  try {
    final docs =
        (await getTargetTable().orderBy(colTargetDate, descending: true).get())
            .docs;
    return docs.map(Target.fromQDS).toList();
  } catch (e) {}
  return [];
}

Future<void> updateTarget(Target target) async {
  try {
    await getTargetTable().doc(target.id).update(Target.toMap(target));
  } catch (e) {}
}

Future<void> deleteTarget(String id) async {
  try {
    await getTargetTable().doc(id).delete();
  } catch (e) {}
}

Future<String> insertExpense(Expense expense) async {
  try {
    final ref = await getExpenseTable().add(expense);
    return ref.id;
  } catch (e) {}
  return "";
}

Future<List<Expense>> getAllExpenses() async {
  try {
    final docs = (await getExpenseTable()
            .orderBy(colExpenseDate, descending: true)
            .get())
        .docs;
    return docs.map(Expense.fromQDS).toList();
  } catch (e) {}
  return [];
}

Future<List<Expense>> getAllExpensesInGivenMonth(DateTime dateTime) async {
  try {
    String firstDay = getFirstDayOfMonth(dateTime).toIso8601String();
    String lastDay = getLastDayOfMonth(dateTime).toIso8601String();
    final docs = (await getExpenseTable()
            .where(colExpenseDate,
                isGreaterThanOrEqualTo: firstDay, isLessThanOrEqualTo: lastDay)
            .orderBy(colExpenseDate, descending: true)
            .get())
        .docs;
    return docs.map(Expense.fromQDS).toList();
  } catch (e) {}
  return [];
}

Future<void> updateExpense(Expense expense) async {
  try {
    await getExpenseTable().doc(expense.id).update(Expense.toMap(expense));
  } catch (e) {}
}

Future<void> deleteExpense(String id) async {
  try {
    await getExpenseTable().doc(id).delete();
  } catch (e) {}
}

Future<List<String>> getExistingCategoriesList() async {
  return (await getAllExpenses())
      .map((expense) => expense.category)
      .toSet()
      .toList();
}

Stream<List<Expense>> allExpensesStream() => getExpenseTable()
    .orderBy(colExpenseDate, descending: true)
    .snapshots()
    .map<List<Expense>>(
        (event) => event.docs.map((e) => Expense.fromQDS(e)).toList());

Stream<List<Target>> allTargetsStream() => getTargetTable()
    .orderBy(colTargetDate, descending: true)
    .snapshots()
    .map<List<Target>>(
        (event) => event.docs.map((t) => Target.fromQDS(t)).toList());
