class BankMapping {
  // Chuyển đổi mã ngân hàng từ BankId sang mã ngân hàng của MoMo
  static String getMomoBankCodeFromBankId(String bankId) {
    // Bảng ánh xạ từ mã ngân hàng trong VietQR sang mã ngân hàng của MoMo
    final Map<String, String> bankMapping = {
      '970436': 'Vietcombank', // Vietcombank
      '970415': 'VietinBank', // VietinBank
      '970418': 'BIDV', // BIDV
      '970422': 'MB', // MB Bank
      '970432': 'VPBank', // VPBank
      '970403': 'Sacombank', // Sacombank
      '970423': 'TPBank', // TPBank
      '970407': 'TechcomBank', // Techcombank
      '970431': 'VIB', // VIB
      '970454': 'VietCapitalBank', // Viet Capital Bank
      '970448': 'OCB', // OCB
      '970449': 'LienVietPostBank', // LienVietPostBank
      '970416': 'ACB', // ACB
      '970441': 'VRB', // VRB
      '970452': 'KienLongBank', // KienLongBank
      '970421': 'VietBank', // VietBank
      '970409': 'BAC A BANK', // BAC A BANK
      '970406': 'DongA', // DongA Bank
      '970429': 'SHB', // SHB
      '970440': 'SeABank', // SeABank
      '970426': 'MSB', // MSB
      '970427': 'VietABank', // VietABank
      '970419': 'NCB', // NCB
      '970412': 'PVcomBank', // PVcomBank
      '970414': 'OceanBank', // OceanBank
      '970438': 'BaoVietBank', // BaoVietBank
      '970442': 'HSBC', // HSBC
      '970458': 'UnitedOverseas', // UnitedOverseas
      '970457': 'WooriBank', // WooriBank
      '970410': 'StandardChartered', // StandardChartered
      '970439': 'PublicBank', // PublicBank
      '970462': 'CIMB', // CIMB
      '970463': 'KookminHN', // KookminHN
      '970446': 'CoopBank', // CoopBank
      '970455': 'IBK', // IBK
      '970430': 'PGBank', // PGBank
      '970400': 'GPBank', // GPBank
      '970456': 'IBK - HCM', // IBK - HCM
      '970464': 'KookminHCM', // KookminHCM
      '970466': 'IVB', // IVB
      '970467': 'NONGHYUP', // NONGHYUP
      '970469': 'KEBHANA', // KEBHANA
      '970468': 'SCBVN', // SCBVN
      '970470': 'SCBVN', // SCBVN
      // ignore: equal_keys_in_map
      '970422': 'MB', // MB
      '796500': 'DBS', // DBS
      '458761': 'HSBC', // HSBC
    };

    return bankMapping[bankId] ?? '';
  }
}
