import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ExpenseDirection { payment, loan_credit, loan_debit }

const String PAYMENT = 'PAYMENT';
const String LOAN_CREDIT = 'LOAN_CREDIT';
const String LOAN_DEBIT = 'LOAN_DEBIT';

const String colExpenseID = 'ExpenseID';
const String colExpenseAmount = 'Amount';
const String colExpenseCategory = 'Category';
const String colExpenseDescription = 'Description';
const String colExpenseDirection = 'Direction';
const String colExpenseDate = 'Date';
const String colExpenseLastEdit = 'LastEdit';
const String colExpenseUUID = 'ExpenseUUID';

const String colTargetID = 'TargetID';
const String colTargetAmount = 'Amount';
const String colTargetDate = 'Date';
const String colTargetLastEdit = 'LastEdit';
const String colTargetUUID = 'TargetUUID';

extension ExpenseDirectionExtensions on ExpenseDirection {
  String toExpenseDirectionString() {
    switch (this) {
      case ExpenseDirection.payment:
        return PAYMENT;
      case ExpenseDirection.loan_credit:
        return LOAN_CREDIT;
      case ExpenseDirection.loan_debit:
        return LOAN_DEBIT;
      default:
        return 'UNKNOWN';
    }
  }

  String toExpenseDirectionUIString() {
    switch (this) {
      case ExpenseDirection.payment:
        return 'Payment';
      case ExpenseDirection.loan_credit:
        return 'Credit';
      case ExpenseDirection.loan_debit:
        return 'Debit';
      default:
        return 'Unknown';
    }
  }

  Icon icon() {
    switch (this) {
      case ExpenseDirection.payment:
        return const Icon(Icons.attach_money);
      case ExpenseDirection.loan_credit:
        return const Icon(Icons.warning_amber);
      case ExpenseDirection.loan_debit:
        return const Icon(Icons.credit_card);
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

  static List<dynamic> toExcelRow(Expense expense) => [
        expense.id,
        expense.amount,
        expense.category,
        expense.description,
        expense.direction.toExpenseDirectionUIString(),
        DateFormat.yMMMMd().format(expense.date),
        DateFormat.yMMMMEEEEd().format(expense.lastEdit),
      ];
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

  static List<dynamic> toExcelRow(Target target) => [
        target.id,
        target.amount,
        DateFormat.yMMMM().format(target.date),
        DateFormat.yMMMMEEEEd().format(target.lastEdit),
      ];
}

class TargetDeltaUnit {
  String text;
  Icon icon;

  TargetDeltaUnit(this.text, this.icon);
}

final TargetDeltaUnit loadingTargetDeltaUnit = TargetDeltaUnit(
  'Loading',
  const Icon(Icons.calculate, color: Colors.yellow),
);

/// Chart Type for BarPieChart page.
enum ChartType { bar, pie }

extension UiString on ChartType {
  String toUiString() => this == ChartType.bar ? 'Bar' : 'Pie';
}

/// Data model for BarPieChart page.
class ChartData {
  String category;
  double expenseSum;

  ChartData(this.category, this.expenseSum);
}

/// Handles the AggregateBy Choice Chips state.
enum AggregateBy { month, day }

extension UIStrings on AggregateBy {
  String toUiString() => this == AggregateBy.month ? 'Month' : 'Day';
}

enum AppPermissions { sms, readNotif, postNotif }

extension PermText on AppPermissions {
  String text() {
    switch (this) {
      case AppPermissions.sms:
        return 'Read SMS for auto-capturing expenses';
      case AppPermissions.readNotif:
        return 'Read user notifications for auto-capturing expenses';
      case AppPermissions.postNotif:
        return 'Push notifications for new expenses';
    }
  }
}

enum AppPermissionStatus { granted, loading, denied }

extension PermIcon on AppPermissionStatus {
  Icon icon() {
    switch (this) {
      case AppPermissionStatus.granted:
        return const Icon(Icons.check);
      case AppPermissionStatus.loading:
        return const Icon(Icons.hourglass_bottom_outlined);
      case AppPermissionStatus.denied:
        return const Icon(Icons.clear);
    }
  }
}

const String messagingPackage = 'com.google.android.apps.messaging';
const String paytmPackage = 'net.one97.paytm';
const String phonepePackage = 'com.phonepe.app';
const String gpayPackage = 'com.google.android.apps.nbu.paisa.user';
const String sbiPackage = 'com.sbi.lotusintouch';
const String iciciPackage = 'com.csam.icici.bank.imobile';

enum CapturedNotificationType {
  paytmMessage,
  phonepeMessage,
  gpayMessage,
  sbiMessage,
  iciciMessage,
  paytmNotif,
  phonepeNotif,
  gpayNotif,
  sbiNotif,
  iciciNotif,
  unknown
}

class CapturedNotification {
  static final allowedPackages = [
    paytmPackage,
    phonepePackage,
    iciciPackage,
    sbiPackage,
    gpayPackage
  ];
  static final phoneNumbers = ['7809601401', '9337198649'];
  static const amountThreshold = 100000;
  final String? packageName;
  final String? sender;
  final String? content;
  late CapturedNotificationType type;
  double? _amount;

  CapturedNotification(this.packageName, this.sender, this.content) {
    findType();
  }

  /// Finds out the type of notification based on the package, received content
  /// and the amount.
  void findType() {
    type = CapturedNotificationType.unknown;
    if (packageName == phonepePackage) {
      type = CapturedNotificationType.phonepeNotif;
    } else if (packageName == paytmPackage) {
      type = CapturedNotificationType.paytmNotif;
    } else if (packageName == gpayPackage) {
      type = CapturedNotificationType.gpayNotif;
    } else if (packageName == iciciPackage) {
      type = CapturedNotificationType.iciciNotif;
    } else if (packageName == sbiPackage) {
      type = CapturedNotificationType.sbiNotif;
    } else if (sender != null) {
      if (sender!.toLowerCase().contains('paytm') ||
          content!.toLowerCase().contains('paytm')) {
        type = CapturedNotificationType.paytmMessage;
      } else if (sender!.toLowerCase().contains('phonepe') ||
          content!.toLowerCase().contains('phonepe')) {
        type = CapturedNotificationType.phonepeMessage;
      } else if (sender!.toLowerCase().contains('icici') ||
          content!.toLowerCase().contains('icici')) {
        type = CapturedNotificationType.iciciMessage;
      } else if (sender!.toLowerCase().contains('sbi') ||
          content!.toLowerCase().contains('sbi')) {
        type = CapturedNotificationType.sbiMessage;
      } else if (sender!.toLowerCase().contains('gpay') ||
          content!.toLowerCase().contains('gpay')) {
        type = CapturedNotificationType.gpayMessage;
      }
    }

    if (isAmountSuspicious()) {
      type = CapturedNotificationType.unknown;
    }
  }

  bool isUnknown() => type == CapturedNotificationType.unknown;

  bool isOtpMessage() =>
      content != null && content!.toLowerCase().contains('otp');

  bool containsPhoneNumber() {
    if (content == null) return false;
    bool containsPhone = false;
    for (String phone in CapturedNotification.phoneNumbers) {
      containsPhone |= content!.contains(phone);
    }
    return containsPhone;
  }

  /// To be termed as a payment message,
  /// 1. the type should not be declared as unknown,
  /// 2. the content should be non-null,
  /// 3. should not be an OTP message,
  /// 4. should not contain phone numbers in its content.
  bool isPayment() {
    return !(isUnknown() ||
        content == null ||
        isOtpMessage() ||
        containsPhoneNumber());
  }

  //TODO: Refine
  /// 1. If Amount is pre-calculated, return it.
  /// 2. If the captured notification fails the payment message criteria check,
  /// or is an unknown notification, return -1.
  /// 3. Split the content by spaces. If there is no string that starts with
  /// 'Rs.' or 'Rs' and has a number after it, return -1. Else return the parsed
  /// amount from the numeric string.
  double getAmount() {
    if (_amount != null) {
      return _amount!;
    }
    double result = -1;
    if (!isPayment()) {
      _amount = result;
      return _amount!;
    }
    final splits = content!.split(' ');
    switch (type) {
      case CapturedNotificationType.paytmMessage:
      case CapturedNotificationType.phonepeMessage:
      case CapturedNotificationType.iciciMessage:
      case CapturedNotificationType.sbiMessage:
      case CapturedNotificationType.gpayMessage:
      case CapturedNotificationType.paytmNotif:
      case CapturedNotificationType.phonepeNotif:
      case CapturedNotificationType.iciciNotif:
      case CapturedNotificationType.sbiNotif:
      case CapturedNotificationType.gpayNotif:
        for (String s in splits) {
          if (s.startsWith('Rs.')) {
            s = s.substring(3);
          } else if (s.startsWith('Rs')) {
            s = s.substring(2);
          }
          if (s.isNotEmpty && double.tryParse(s) != null) {
            result = double.tryParse(s)!;
            break;
          }
        }
        break;
      case CapturedNotificationType.unknown:
        result = -1;
        break;
    }
    _amount = result;
    return _amount!;
  }

  /// Returns whether there is no valid amount, or if the amount is beyond
  /// a sensible threshold.
  bool isAmountSuspicious() =>
      getAmount() == -1 || getAmount() >= amountThreshold;

  /// Description for the `Expense` model to be created from the captured
  /// notification.
  String getDescription() {
    switch (type) {
      case CapturedNotificationType.paytmMessage:
        return 'From Paytm Message';
      case CapturedNotificationType.paytmNotif:
        return 'From Paytm Notification';
      case CapturedNotificationType.phonepeMessage:
        return 'From PhonePe Message';
      case CapturedNotificationType.phonepeNotif:
        return 'From PhonePe Notification';
      case CapturedNotificationType.iciciMessage:
        return 'From ICICI Message';
      case CapturedNotificationType.iciciNotif:
        return 'From ICICI Notification';
      case CapturedNotificationType.gpayMessage:
        return 'From GPay Message';
      case CapturedNotificationType.gpayNotif:
        return 'From GPay Notification';
      case CapturedNotificationType.sbiMessage:
        return 'From SBI Message';
      case CapturedNotificationType.sbiNotif:
        return 'From SBI Notification';
      case CapturedNotificationType.unknown:
        return 'Unknown Notification';
    }
  }

  //TODO: Refine
  String getCategory() {
    return 'Expense';
  }

  //TODO: Refine
  ExpenseDirection getDirection() {
    return ExpenseDirection.payment;
  }
}
