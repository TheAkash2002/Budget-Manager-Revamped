import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseDirection { payment, loan_credit, loan_debit }

const String PAYMENT = "PAYMENT";
const String LOAN_CREDIT = "LOAN_CREDIT";
const String LOAN_DEBIT = "LOAN_DEBIT";

const String colExpenseID = "ExpenseID";
const String colExpenseAmount = "Amount";
const String colExpenseCategory = "Category";
const String colExpenseDescription = "Description";
const String colExpenseDirection = "Direction";
const String colExpenseDate = "Date";
const String colExpenseLastEdit = "LastEdit";
const String colExpenseUUID = "ExpenseUUID";

const String colTargetID = "TargetID";
const String colTargetAmount = "Amount";
const String colTargetDate = "Date";
const String colTargetLastEdit = "LastEdit";
const String colTargetUUID = "TargetUUID";

extension ExpenseDirectionStrings on ExpenseDirection {
  String toExpenseDirectionString() {
    switch (this) {
      case ExpenseDirection.payment:
        return PAYMENT;
      case ExpenseDirection.loan_credit:
        return LOAN_CREDIT;
      case ExpenseDirection.loan_debit:
        return LOAN_DEBIT;
      default:
        return "UNKNOWN";
    }
  }

  String toExpenseDirectionUIString() {
    switch (this) {
      case ExpenseDirection.payment:
        return "Payment";
      case ExpenseDirection.loan_credit:
        return "Credit";
      case ExpenseDirection.loan_debit:
        return "Debit";
      default:
        return "Unknown";
    }
  }
}

ExpenseDirection fromExpenseDirectionString(String direction) {
  switch (direction) {
    case PAYMENT:
      return ExpenseDirection.payment;
    case LOAN_CREDIT:
      return ExpenseDirection.loan_credit;
    case LOAN_DEBIT:
      return ExpenseDirection.loan_debit;
    default:
      throw Exception();
  }
}

class Expense {
  String id;
  double amount;
  String category;
  String description;
  ExpenseDirection direction;
  DateTime date;
  DateTime lastEdit;
  String? uuid;

  Expense(
      {required this.id,
      required this.amount,
      required this.category,
      required this.description,
      required this.direction,
      required this.date,
      required this.lastEdit});

  static Map<String, dynamic> toMap(Expense expense) {
    Map<String, dynamic> res = {
      //colExpenseID: id,
      colExpenseAmount: expense.amount,
      colExpenseDescription: expense.description,
      colExpenseCategory: expense.category,
      colExpenseDirection: expense.direction.toExpenseDirectionString(),
      colExpenseDate: expense.date.toIso8601String(),
      colExpenseLastEdit: expense.lastEdit.toIso8601String(),
    };

    if (expense.uuid != null) {
      res[colExpenseUUID] = expense.uuid;
    }

    return res;
  }

  static Expense fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final map = snapshot.data()!;
    Expense res = Expense(
      id: snapshot.id,
      amount: double.parse(map[colExpenseAmount].toString()),
      category: map[colExpenseCategory],
      description: map[colExpenseDescription],
      direction: fromExpenseDirectionString(map[colExpenseDirection]),
      date: DateTime.parse(map[colExpenseDate]),
      lastEdit: DateTime.parse(map[colExpenseLastEdit]),
    );
    if (map.containsKey(colExpenseUUID)) {
      res.uuid = map[colExpenseUUID];
    }
    return res;
  }

  static Expense fromQDS(QueryDocumentSnapshot<Expense> qds) {
    return qds.data();
  }
}

class Target {
  String id;
  double amount;
  DateTime date;
  DateTime lastEdit;
  String? uuid;

  Target(
      {required this.id,
      required this.amount,
      required this.date,
      required this.lastEdit,
      this.uuid});

  static Map<String, dynamic> toMap(Target target) {
    Map<String, dynamic> res = {
      //colTargetID: id,
      colTargetAmount: target.amount,
      colTargetDate: target.date.toIso8601String(),
      colTargetLastEdit: target.lastEdit.toIso8601String(),
    };
    if (target.uuid != null) {
      res[colTargetUUID] = target.uuid;
    }
    return res;
  }

  static Target fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final map = snapshot.data()!;
    Target res = Target(
      id: snapshot.id,
      amount: double.parse(map[colTargetAmount].toString()),
      date: DateTime.parse(map[colTargetDate]),
      lastEdit: DateTime.parse(map[colTargetLastEdit]),
    );
    if (map.containsKey(colExpenseUUID)) {
      res.uuid = map[colExpenseUUID];
    }
    return res;
  }

  static Target fromQDS(QueryDocumentSnapshot<Target> qds) {
    return qds.data();
  }
}
