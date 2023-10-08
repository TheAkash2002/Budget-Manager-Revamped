import '../models/models.dart';

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
  static final phoneNumbers = ["7809601401", "9337198649"];
  static const AMOUNT_THRESHOLD = 100000;
  final String? packageName;
  final String? sender;
  final String? content;
  late CapturedNotificationType type;
  double? _amount;

  CapturedNotification(this.packageName, this.sender, this.content) {
    findType();
  }

  void findType() {
    type = CapturedNotificationType.UNKNOWN;
    if (packageName == PHONEPE_PACKAGE) {
      type = CapturedNotificationType.PHONEPE_NOTIF;
    } else if (packageName == PAYTM_PACKAGE) {
      type = CapturedNotificationType.PAYTM_NOTIF;
    } else if (packageName == GPAY_PACKAGE) {
      type = CapturedNotificationType.GPAY_NOTIF;
    } else if (packageName == ICICI_PACKAGE) {
      type = CapturedNotificationType.ICICI_NOTIF;
    } else if (packageName == SBI_PACKAGE) {
      type = CapturedNotificationType.SBI_NOTIF;
    } else if (sender != null) {
      if (sender!.toLowerCase().contains("paytm") ||
          content!.toLowerCase().contains("paytm")) {
        type = CapturedNotificationType.PAYTM_MESSAGE;
      } else if (sender!.toLowerCase().contains("phonepe") ||
          content!.toLowerCase().contains("phonepe")) {
        type = CapturedNotificationType.PHONEPE_MESSAGE;
      } else if (sender!.toLowerCase().contains("icici") ||
          content!.toLowerCase().contains("icici")) {
        type = CapturedNotificationType.ICICI_MESSAGE;
      } else if (sender!.toLowerCase().contains("sbi") ||
          content!.toLowerCase().contains("sbi")) {
        type = CapturedNotificationType.SBI_MESSAGE;
      } else if (sender!.toLowerCase().contains("gpay") ||
          content!.toLowerCase().contains("gpay")) {
        type = CapturedNotificationType.GPAY_MESSAGE;
      }
    }

    if (isAmountSuspicious()) {
      type = CapturedNotificationType.UNKNOWN;
    }
  }

  bool isUnknown() => type == CapturedNotificationType.UNKNOWN;

  bool isOtpMessage() =>
      content != null && (content!.contains("OTP") || content!.contains("otp"));

  bool containsPhoneNumber() {
    if (content == null) return false;
    bool containsPhone = false;
    for (String phone in CapturedNotification.phoneNumbers) {
      containsPhone |= content!.contains(phone);
    }
    return containsPhone;
  }

  bool isPayment() {
    return !(isUnknown() ||
        content == null ||
        isOtpMessage() ||
        containsPhoneNumber());
  }

  //TODO: Refine
  double getAmount() {
    if (_amount != null) {
      return _amount!;
    }
    double result = -1;
    if (!isPayment()) {
      _amount = result;
      return _amount!;
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
    _amount = result;
    return _amount!;
  }

  bool isAmountSuspicious() =>
      getAmount() == -1 || getAmount() >= AMOUNT_THRESHOLD;

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
