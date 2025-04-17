import 'dart:convert';

/// Lớp phân tích mã QR VietQR
class VietQRParser {
  static const Map<String, String> FIELD_NAMES = {
    "00": "Payload Format Indicator",
    "01": "Point of Initiation Method",
    "38": "Merchant Account Information - NAPAS",
    "52": "Merchant Category Code",
    "53": "Transaction Currency",
    "54": "Transaction Amount",
    "55": "Tip or Convenience Indicator",
    "56": "Value of Convenience Fee Fixed",
    "57": "Value of Convenience Fee Percentage",
    "58": "Country Code",
    "59": "Merchant Name",
    "60": "Merchant City",
    "61": "Postal Code",
    "62": "Additional Data Fields",
    "63": "CRC (Cyclic Redundancy Check)",
    "64": "Merchant Information - Language",
  };

  static const Map<String, Map<String, dynamic>> TEMPLATE_FIELDS = {
    "38": {
      "00": "Global Unique Identifier - GUID",
      "01": {
        "field_name": "Payment Network Specific",
        "sub_fields": {
          "00": "Acquirer ID/BNB ID",
          "01": "Merchant ID/Consumer ID",
        }
      },
      "02": "Service Code",
    },
    "62": {
      "01": "Bill Number",
      "02": "Mobile Number",
      "03": "Store Label",
      "04": "Loyalty Number",
      "05": "Reference Label",
      "06": "Customer Label",
      "07": "Terminal Label",
      "08": "Purpose of Transaction",
      "09": "Additional Consumer Data Request",
    },
  };

  static const Map<String, Map<String, String>> LOOKUP_TABLES = {
    "Service Code": {
      "QRPUSH": "Product Payment",
      "QRCASH": "Cash Withdrawal",
      "QRIBFTTA": "Inter-Bank Fund Transfer 24/7 to Account",
      "QRIBFTTC": "Inter-Bank Fund Transfer 24/7 to Card",
    },
    "Acquirer ID/BNB ID": {
      "970425": "ABB - ABBANK",
      "970416": "ACB - ACB",
      "970409": "BAB - BacABank",
      "970418": "BIDV - BIDV",
      "970438": "BVB - BaoVietBank",
      "546034": "CAKE - CAKE",
      "970444": "CBB - CBBank",
      "422589": "CIMB - CIMB",
      "970446": "COOPBANK - COOPBANK",
      "796500": "DBS - DBSBank",
      "970406": "DOB - DongABank",
      "970431": "EIB - Eximbank",
      "970408": "GPB - GPBank",
      "970437": "HDB - HDBank",
      "970442": "HLBVN - HongLeong",
      "458761": "HSBC - HSBC",
      "970456": "IBK-HCM - IBKHCM",
      "970455": "IBK-HN - IBKHN",
      "970415": "ICB - VietinBank",
      "970434": "IVB - IndovinaBank",
      "668888": "KBank - KBank",
      "970463": "KBHCM - KookminHCM",
      "970462": "KBHN - KookminHN",
      "970452": "KLB - KienLongBank",
      "970449": "LPB - LienVietPostBank",
      "970422": "MB - MBBank",
      "970426": "MSB - MSB",
      "970428": "NAB - NamABank",
      "970419": "NCB - NCB",
      "801011": "NHB HN - Nonghyup",
      "970448": "OCB - OCB",
      "970414": "Oceanbank - Oceanbank",
      "970439": "PBVN - PublicBank",
      "970430": "PGB - PGBank",
      "970412": "PVCB - PVcomBank",
      "970429": "SCB - SCB",
      "970410": "SCVN - StandardChartered",
      "970440": "SEAB - SeABank",
      "970400": "SGICB - SaigonBank",
      "970443": "SHB - SHB",
      "970424": "SHBVN - ShinhanBank",
      "970403": "STB - Sacombank",
      "970407": "TCB - Techcombank",
      "970423": "TPB - TPBank",
      "546035": "Ubank - Ubank",
      "970458": "UOB - UnitedOverseas",
      "970427": "VAB - VietABank",
      "970405": "VBA - Agribank",
      "970436": "VCB - Vietcombank",
      "970454": "VCCB - VietCapitalBank",
      "970441": "VIB - VIB",
      "970433": "VIETBANK - VietBank",
      "971011": "VNPTMONEY - VNPTMoney",
      "970432": "VPB - VPBank",
      "970421": "VRB - VRB",
      "971005": "VTLMONEY - ViettelMoney",
      "970457": "WVN - Woori",
    },
    "Transaction Currency": {
      "704": "VND - Vietnamese Dong",
    },
    "Country Code": {
      "VN": "Viet Nam",
    },
  };

  final String qrData;
  Map<String, dynamic> parsedData = {};
  Map<String, dynamic> extractedInfo = {};

  VietQRParser(this.qrData);

  /// Kiểm tra mã QR có phải là VietQR không
  bool isVietQR() {
    return qrData.startsWith('00020101');
  }

  /// Phân tích mã QR
  void parse() {
    if (!isVietQR()) {
      parsedData["Invalid VietQR code"] = qrData;
      return;
    }

    int index = 0;
    final int length = qrData.length;

    while (index < length - 4) {
      // Trừ 4 ký tự cuối là CRC
      final result = _extractField(qrData, index);
      final String dataId = result['data_id'];
      final String dataValue = result['data_value'];
      index = result['newIndex'];

      final String fieldName = FIELD_NAMES[dataId] ?? "Unknown Field";
      final String fieldKey = "($dataId) $fieldName";

      if (TEMPLATE_FIELDS.containsKey(dataId)) {
        parsedData[fieldKey] =
            _parseNestedFields(dataValue, TEMPLATE_FIELDS[dataId]!);
      } else {
        parsedData[fieldKey] = dataValue;
      }
    }

    _extractPaymentInfo();
  }

  /// Trích xuất thông tin thanh toán từ dữ liệu đã phân tích
  void _extractPaymentInfo() {
    // Lấy thông tin ngân hàng
    if (parsedData.containsKey("(38) Merchant Account Information - NAPAS")) {
      final napasInfo = parsedData["(38) Merchant Account Information - NAPAS"];

      // Lấy mã ngân hàng
      if (napasInfo.containsKey("(01) Payment Network Specific")) {
        final paymentInfo = napasInfo["(01) Payment Network Specific"];
        if (paymentInfo.containsKey("(00) Acquirer ID/BNB ID")) {
          final bankId = paymentInfo["(00) Acquirer ID/BNB ID"].split(" ")[0];
          extractedInfo["bankId"] = bankId;

          // Lấy tên ngân hàng
          final bankInfo = LOOKUP_TABLES["Acquirer ID/BNB ID"]?[bankId];
          if (bankInfo != null) {
            extractedInfo["bankName"] = bankInfo.split(" - ")[1];
          }
        }

        // Lấy số tài khoản
        if (paymentInfo.containsKey("(01) Merchant ID/Consumer ID")) {
          extractedInfo["accountNumber"] =
              paymentInfo["(01) Merchant ID/Consumer ID"];
        }
      }

      // Lấy loại dịch vụ
      if (napasInfo.containsKey("(02) Service Code")) {
        final serviceCode = napasInfo["(02) Service Code"].split(" ")[0];
        extractedInfo["serviceCode"] = serviceCode;
      }
    }

    // Lấy tên người nhận
    if (parsedData.containsKey("(59) Merchant Name")) {
      extractedInfo["beneficiaryName"] = parsedData["(59) Merchant Name"];
    }

    // Lấy số tiền
    if (parsedData.containsKey("(54) Transaction Amount")) {
      extractedInfo["amount"] = parsedData["(54) Transaction Amount"];
    }

    // Lấy nội dung chuyển khoản
    if (parsedData.containsKey("(62) Additional Data Fields")) {
      final additionalData = parsedData["(62) Additional Data Fields"];
      if (additionalData.containsKey("(08) Purpose of Transaction")) {
        extractedInfo["description"] =
            additionalData["(08) Purpose of Transaction"];
      }
    }
  }

  /// Phân tích các trường con
  Map<String, dynamic> _parseNestedFields(
      String data, Map<String, dynamic> template) {
    final Map<String, dynamic> result = {};
    int index = 0;
    final int length = data.length;

    while (index < length) {
      final extractResult = _extractField(data, index);
      final String dataId = extractResult['data_id'];
      final String dataValue = extractResult['data_value'];
      index = extractResult['newIndex'];

      if (template.containsKey(dataId)) {
        final fieldTemplate = template[dataId];

        if (fieldTemplate is Map && fieldTemplate.containsKey("sub_fields")) {
          final String fieldName =
              fieldTemplate["field_name"] ?? "Unknown Sub-Field";
          result["($dataId) $fieldName"] =
              _parseNestedFields(dataValue, fieldTemplate["sub_fields"]);
        } else {
          final String fieldName = fieldTemplate;
          result["($dataId) $fieldName"] = dataValue;
        }
      } else {
        result["($dataId) Unknown Sub-field"] = dataValue;
      }
    }

    return result;
  }

  /// Trích xuất một trường từ chuỗi dữ liệu
  Map<String, dynamic> _extractField(String data, int startIndex) {
    final String dataId = data.substring(startIndex, startIndex + 2);
    final int fieldLength =
        int.parse(data.substring(startIndex + 2, startIndex + 4));
    final String dataValue =
        data.substring(startIndex + 4, startIndex + 4 + fieldLength);

    return {
      'data_id': dataId,
      'fieldLength': fieldLength,
      'data_value': dataValue,
      'newIndex': startIndex + 4 + fieldLength,
    };
  }

  /// Tạo deeplink cho MoMo với thông tin từ mã QR
  String createMoMoDeeplink() {
    if (extractedInfo.isEmpty) {
      parse();
    }

    if (extractedInfo.isEmpty) {
      return 'momo://';
    }

    // Tạo deeplink theo cách mới nhất của MoMo
    // Dựa trên hình ảnh đã chia sẻ, MoMo sử dụng action=payWithQrCode để mở màn hình chuyển khoản
    String deeplink = 'momo://?action=payWithQrCode';

    // Truyền toàn bộ mã QR gốc
    deeplink += '&rawData=$qrData';

    // Thêm các tham số cần thiết
    if (extractedInfo.containsKey("accountNumber")) {
      deeplink +=
          '&sourceText=${Uri.encodeComponent(extractedInfo["accountNumber"])}';
    }

    if (extractedInfo.containsKey("bankId")) {
      deeplink += '&bankCode=${Uri.encodeComponent(extractedInfo["bankId"])}';
    }

    if (extractedInfo.containsKey("bankName")) {
      deeplink += '&bankName=${Uri.encodeComponent(extractedInfo["bankName"])}';
    }

    if (extractedInfo.containsKey("beneficiaryName")) {
      deeplink +=
          '&receiverName=${Uri.encodeComponent(extractedInfo["beneficiaryName"])}';
    }

    if (extractedInfo.containsKey("amount")) {
      deeplink += '&amount=${Uri.encodeComponent(extractedInfo["amount"])}';
    }

    if (extractedInfo.containsKey("description")) {
      deeplink +=
          '&comment=${Uri.encodeComponent(extractedInfo["description"])}';
    } else {
      // Thêm nội dung mặc định nếu không có
      deeplink += '&comment=Chuyen tien qua QR';
    }

    return deeplink;
  }

  /// Tạo deeplink cho ZaloPay với thông tin từ mã QR
  String createZaloPayDeeplink() {
    if (extractedInfo.isEmpty) {
      parse();
    }

    if (extractedInfo.isEmpty) {
      return 'zalopay://';
    }

    // ZaloPay sử dụng tham số zpw_qrdata để truyền toàn bộ mã QR
    return 'zalopay://?zpw_qrdata=$qrData';
  }

  /// Tạo deeplink cho ViettelPay với thông tin từ mã QR
  String createViettelPayDeeplink() {
    if (extractedInfo.isEmpty) {
      parse();
    }

    if (extractedInfo.isEmpty) {
      return 'viettelmoney://';
    }

    // ViettelPay sử dụng tham số qrData để truyền toàn bộ mã QR
    return 'viettelmoney://?action=qrScan&qrData=$qrData';
  }

  /// Tạo deeplink cho VNPAY với thông tin từ mã QR
  String createVNPayDeeplink() {
    if (extractedInfo.isEmpty) {
      parse();
    }

    if (extractedInfo.isEmpty) {
      return 'vnpay://';
    }

    // VNPAY sử dụng tham số qrCodeData để truyền toàn bộ mã QR
    return 'vnpay://?action=qrScan&qrCodeData=$qrData';
  }

  /// Tạo deeplink cho ngân hàng với thông tin từ mã QR
  String createBankDeeplink(String bankKey) {
    if (extractedInfo.isEmpty) {
      parse();
    }

    switch (bankKey.toLowerCase()) {
      case 'momo':
        return createMoMoDeeplink();
      case 'zalopay':
        return createZaloPayDeeplink();
      case 'viettel':
        return createViettelPayDeeplink();
      case 'vnpay':
        return createVNPayDeeplink();
      default:
        // Đối với các ngân hàng khác, sử dụng tham số qrcode để truyền toàn bộ mã QR
        final bankScheme = BankSchemes.bankApps[bankKey]?['scheme'];
        if (bankScheme != null) {
          return '$bankScheme?qrcode=$qrData';
        }
        return '';
    }
  }
}

/// Lớp chứa thông tin về các ứng dụng ngân hàng
class BankSchemes {
  static final Map<String, Map<String, String>> bankApps = {
    'momo': {
      'scheme': 'momo://',
      'package': 'com.mservice.momotransfer',
      'name': 'MoMo',
    },
    'zalopay': {
      'scheme': 'zalopay://',
      'package': 'vn.com.vng.zalopay',
      'name': 'ZaloPay',
    },
    'vnpay': {
      'scheme': 'vnpay://',
      'package': 'com.vnpay.wallet',
      'name': 'VNPAY',
    },
    'viettel': {
      'scheme': 'viettelmoney://',
      'package': 'com.viettel.viettelmoney',
      'name': 'Viettel Money',
    },
    'vcb': {
      'scheme': 'vietcombankmobile://',
      'package': 'com.VCB',
      'name': 'Vietcombank',
    },
    'bidv': {
      'scheme': 'bidv://',
      'package': 'com.vnpay.bidv',
      'name': 'BIDV',
    },
    'vib': {
      'scheme': 'vib://',
      'package': 'com.vn.vib.mobilebanking',
      'name': 'VIB',
    },
    'vpbank': {
      'scheme': 'vpbankonline://',
      'package': 'com.vpbank.vpbankneo',
      'name': 'VPBank',
    },
    'techcombank': {
      'scheme': 'tcb://',
      'package': 'vn.com.techcombank.bb.app',
      'name': 'Techcombank',
    },
    'mbbank': {
      'scheme': 'mbmobile://',
      'package': 'com.mbmobile',
      'name': 'MB Bank',
    },
    'acb': {
      'scheme': 'acb://',
      'package': 'mobile.acb.com.vn',
      'name': 'ACB',
    },
    'tpbank': {
      'scheme': 'tpbankmobile://',
      'package': 'com.tpb.mb.gprsandroid',
      'name': 'TPBank',
    },
    'agribank': {
      'scheme': 'agribankmobile://',
      'package': 'com.vnpay.agribank',
      'name': 'Agribank',
    },
    'sacombank': {
      'scheme': 'sacombankmobile://',
      'package': 'com.sacombank.sbmobile',
      'name': 'Sacombank',
    },
    'hdbank': {
      'scheme': 'hdbankmobile://',
      'package': 'com.hdbank.mobilebanking',
      'name': 'HDBank',
    },
    'ocb': {
      'scheme': 'ocb://',
      'package': 'com.ocb.omniapp',
      'name': 'OCB',
    },
    'shb': {
      'scheme': 'shbmobile://',
      'package': 'vn.shb.mbanking',
      'name': 'SHB',
    },
    'eximbank': {
      'scheme': 'eximbankmobile://',
      'package': 'com.vnpay.eximbank',
      'name': 'Eximbank',
    },
    'vietinbank': {
      'scheme': 'vietinbankmobile://',
      'package': 'com.vietinbank.ipay',
      'name': 'VietinBank',
    },
  };
}
