import 'package:budget_manager_revamped/models/models.dart';

const String MESSAGER_PACKAGE = "com.google.android.apps.messaging";
const String PAYTM_PACKAGE = "net.one97.paytm";
const String PHONEPE_PACKAGE = "com.phonepe.app";
const String GPAY_PACKAGE = "com.google.android.apps.nbu.paisa.user";
const String SBI_PACKAGE = "com.sbi.lotusintouch";
const String ICICI_PACKAGE = "com.csam.icici.bank.imobile";

enum CapturedNotificationType {
  PAYTM_MESSAGE,
  PHONEPE_MESSAGE,
  GPAY_MESSAGE,
  SBI_MESSAGE,
  ICICI_MESSAGE,
  PAYTM_NOTIF,
  PHONEPE_NOTIF,
  GPAY_NOTIF,
  SBI_NOTIF,
  ICICI_NOTIF,
  UNKNOWN
}

class CapturedNotification {
  static final allowedPackages = [
    PAYTM_PACKAGE,
    PHONEPE_PACKAGE,
    ICICI_PACKAGE,
    SBI_PACKAGE,
    GPAY_PACKAGE
  ];
  final String? packageName;
  final String? sender;
  final String? content;
  late CapturedNotificationType type;

  CapturedNotification(this.packageName, this.sender, this.content) {
    type = findType();
    if (type != CapturedNotificationType.UNKNOWN && getAmount() == -1) {
      type = CapturedNotificationType.UNKNOWN;
    }
  }

  CapturedNotificationType findType() {
    if (packageName == PHONEPE_PACKAGE) {
      return CapturedNotificationType.PHONEPE_NOTIF;
    }
    if (packageName == PAYTM_PACKAGE) {
      return CapturedNotificationType.PAYTM_NOTIF;
    }
    if (packageName == GPAY_PACKAGE) {
      return CapturedNotificationType.GPAY_NOTIF;
    }
    if (packageName == ICICI_PACKAGE) {
      return CapturedNotificationType.ICICI_NOTIF;
    }
    if (packageName == SBI_PACKAGE) {
      return CapturedNotificationType.SBI_NOTIF;
    }
    if (sender != null) {
      if (sender!.toLowerCase().contains("paytm") ||
          content!.toLowerCase().contains("paytm")) {
        return CapturedNotificationType.PAYTM_MESSAGE;
      }
      if (sender!.toLowerCase().contains("phonepe") ||
          content!.toLowerCase().contains("phonepe")) {
        return CapturedNotificationType.PHONEPE_MESSAGE;
      }
      if (sender!.toLowerCase().contains("icici") ||
          content!.toLowerCase().contains("icici")) {
        return CapturedNotificationType.ICICI_MESSAGE;
      }
      if (sender!.toLowerCase().contains("sbi") ||
          content!.toLowerCase().contains("sbi")) {
        return CapturedNotificationType.SBI_MESSAGE;
      }
      if (sender!.toLowerCase().contains("gpay") ||
          content!.toLowerCase().contains("gpay")) {
        return CapturedNotificationType.GPAY_MESSAGE;
      }
    }
    return CapturedNotificationType.UNKNOWN;
  }

  bool isUnknown() => type == CapturedNotificationType.UNKNOWN;

  //TODO: Refine
  double getAmount() {
    double result = -1;
    if (content == null) {
      return result;
    }
    final splits = content!.split(" ");
    switch (type) {
      case CapturedNotificationType.PAYTM_MESSAGE:
      case CapturedNotificationType.PHONEPE_MESSAGE:
      case CapturedNotificationType.ICICI_MESSAGE:
      case CapturedNotificationType.SBI_MESSAGE:
      case CapturedNotificationType.GPAY_MESSAGE:
      case CapturedNotificationType.PAYTM_NOTIF:
      case CapturedNotificationType.PHONEPE_NOTIF:
      case CapturedNotificationType.ICICI_NOTIF:
      case CapturedNotificationType.SBI_NOTIF:
      case CapturedNotificationType.GPAY_NOTIF:
        for (String s in splits) {
          if (s.startsWith("Rs.")) {
            s = s.substring(3);
          } else if (s.startsWith("Rs")) {
            s = s.substring(2);
          }
          if (s.isNotEmpty && double.tryParse(s) != null) {
            result = double.tryParse(s)!;
            break;
          }
        }
        break;
      case CapturedNotificationType.UNKNOWN:
        result = -1;
        break;
    }
    return result;
  }

  String getDescription() {
    switch (type) {
      case CapturedNotificationType.PAYTM_MESSAGE:
      case CapturedNotificationType.PAYTM_NOTIF:
        return "From Paytm";
      case CapturedNotificationType.PHONEPE_MESSAGE:
      case CapturedNotificationType.PHONEPE_NOTIF:
        return "From PhonePe";
      case CapturedNotificationType.ICICI_MESSAGE:
      case CapturedNotificationType.ICICI_NOTIF:
        return "From ICICI";
      case CapturedNotificationType.GPAY_MESSAGE:
      case CapturedNotificationType.GPAY_NOTIF:
        return "From GPay";
      case CapturedNotificationType.SBI_MESSAGE:
      case CapturedNotificationType.SBI_NOTIF:
        return "From SBI";
      case CapturedNotificationType.UNKNOWN:
        return "Unknown Notification";
    }
  }

  //TODO: Refine
  String getCategory() {
    return "Expense";
  }

  //TODO: Refine
  ExpenseDirection getDirection() {
    return ExpenseDirection.payment;
  }
}
