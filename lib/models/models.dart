import 'package:budget_manager_revamped/utils/database_helper.dart';

enum ExpenseDirection { payment, loan_credit, loan_debit }

const String PAYMENT = "PAYMENT";
const String LOAN_CREDIT = "LOAN_CREDIT";
const String LOAN_DEBIT = "LOAN_DEBIT";

String toExpenseDirectionString(ExpenseDirection direction) {
  switch (direction) {
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
  int id;
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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> res = {
      //colExpenseID: id,
      colExpenseAmount: amount,
      colExpenseDescription: description,
      colExpenseCategory: category,
      colExpenseDirection: toExpenseDirectionString(direction),
      colExpenseDate: date.toIso8601String(),
      colExpenseLastEdit: lastEdit.toIso8601String(),
    };

    if (uuid != null) {
      res[colExpenseUUID] = uuid;
    }

    return res;
  }

  static Expense fromMap(Map<String, dynamic> map) {
    Expense res = Expense(
      id: map[colExpenseID],
      amount: map[colExpenseAmount],
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
}

class Target {
  int id;
  int amount;
  DateTime date;
  DateTime lastEdit;
  String? uuid;

  Target(
      {required this.id,
      required this.amount,
      required this.date,
      required this.lastEdit,
      this.uuid});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> res = {
      colTargetID: id,
      colTargetAmount: amount,
      colTargetDate: date.toIso8601String(),
      colTargetLastEdit: lastEdit.toIso8601String(),
    };
    if (uuid != null) {
      res[colTargetUUID] = uuid;
    }
    return res;
  }

  static Target fromMap(Map<String, dynamic> map) {
    Target res = Target(
      id: map[colTargetID],
      amount: map[colTargetAmount],
      date: DateTime.parse(map[colTargetDate]),
      lastEdit: DateTime.parse(map[colTargetLastEdit]),
    );
    if (map.containsKey(colExpenseUUID)) {
      res.uuid = map[colExpenseUUID];
    }
    return res;
  }
}
