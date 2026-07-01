/// success : true
/// message : "Ledger fetched successfully"
/// data : {"party":{"id":2033,"name":"ABCD Traders Update checking","email":null,"phone":null,"gstNo":null,"address":""},"ledgerType":"SUPPLIER","totalDebit":101079.25,"totalCredit":42841.98,"balance":-58237.27,"entries":[{"date":"2026-05-01","invoiceNo":"jkjj88","particular":"CASH","debit":0,"credit":789.99,"runningBalance":789.99},{"date":"2026-05-03","invoiceNo":null,"particular":"UPI","debit":0,"credit":363.99,"runningBalance":1153.98},{"date":"2026-05-06","invoiceNo":"23333434","particular":"CASH","debit":0,"credit":34455.00,"runningBalance":35608.98},{"date":"2026-05-15","invoiceNo":null,"particular":"Bill","debit":100078.90,"credit":0,"runningBalance":-64469.92},{"date":"2026-06-12","invoiceNo":"dddd","particular":"CASH","debit":0,"credit":3333.00,"runningBalance":-61136.92},{"date":"2026-06-12","invoiceNo":"3ffef","particular":"CASH","debit":0,"credit":456.00,"runningBalance":-60680.92},{"date":"2026-06-13","invoiceNo":"dgg","particular":"CASH","debit":0,"credit":3444.00,"runningBalance":-57236.92},{"date":"2026-06-16","invoiceNo":null,"particular":"Bill","debit":1000.35,"credit":0,"runningBalance":-58237.27}]}

class GetLedgerDetails {
  GetLedgerDetails({
      bool? success, 
      String? message, 
      Data? data,}){
    _success = success;
    _message = message;
    _data = data;
}

  GetLedgerDetails.fromJson(dynamic json) {
    _success = json['success'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _success;
  String? _message;
  Data? _data;
GetLedgerDetails copyWith({  bool? success,
  String? message,
  Data? data,
}) => GetLedgerDetails(  success: success ?? _success,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get success => _success;
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// party : {"id":2033,"name":"ABCD Traders Update checking","email":null,"phone":null,"gstNo":null,"address":""}
/// ledgerType : "SUPPLIER"
/// totalDebit : 101079.25
/// totalCredit : 42841.98
/// balance : -58237.27
/// entries : [{"date":"2026-05-01","invoiceNo":"jkjj88","particular":"CASH","debit":0,"credit":789.99,"runningBalance":789.99},{"date":"2026-05-03","invoiceNo":null,"particular":"UPI","debit":0,"credit":363.99,"runningBalance":1153.98},{"date":"2026-05-06","invoiceNo":"23333434","particular":"CASH","debit":0,"credit":34455.00,"runningBalance":35608.98},{"date":"2026-05-15","invoiceNo":null,"particular":"Bill","debit":100078.90,"credit":0,"runningBalance":-64469.92},{"date":"2026-06-12","invoiceNo":"dddd","particular":"CASH","debit":0,"credit":3333.00,"runningBalance":-61136.92},{"date":"2026-06-12","invoiceNo":"3ffef","particular":"CASH","debit":0,"credit":456.00,"runningBalance":-60680.92},{"date":"2026-06-13","invoiceNo":"dgg","particular":"CASH","debit":0,"credit":3444.00,"runningBalance":-57236.92},{"date":"2026-06-16","invoiceNo":null,"particular":"Bill","debit":1000.35,"credit":0,"runningBalance":-58237.27}]

class Data {
  Data({
      Party? party, 
      String? ledgerType, 
      num? totalDebit, 
      num? totalCredit, 
      num? balance, 
      List<Entries>? entries,}){
    _party = party;
    _ledgerType = ledgerType;
    _totalDebit = totalDebit;
    _totalCredit = totalCredit;
    _balance = balance;
    _entries = entries;
}

  Data.fromJson(dynamic json) {
    _party = json['party'] != null ? Party.fromJson(json['party']) : null;
    _ledgerType = json['ledgerType'];
    _totalDebit = json['totalDebit'];
    _totalCredit = json['totalCredit'];
    _balance = json['balance'];
    if (json['entries'] != null) {
      _entries = [];
      json['entries'].forEach((v) {
        _entries?.add(Entries.fromJson(v));
      });
    }
  }
  Party? _party;
  String? _ledgerType;
  num? _totalDebit;
  num? _totalCredit;
  num? _balance;
  List<Entries>? _entries;
Data copyWith({  Party? party,
  String? ledgerType,
  num? totalDebit,
  num? totalCredit,
  num? balance,
  List<Entries>? entries,
}) => Data(  party: party ?? _party,
  ledgerType: ledgerType ?? _ledgerType,
  totalDebit: totalDebit ?? _totalDebit,
  totalCredit: totalCredit ?? _totalCredit,
  balance: balance ?? _balance,
  entries: entries ?? _entries,
);
  Party? get party => _party;
  String? get ledgerType => _ledgerType;
  num? get totalDebit => _totalDebit;
  num? get totalCredit => _totalCredit;
  num? get balance => _balance;
  List<Entries>? get entries => _entries;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_party != null) {
      map['party'] = _party?.toJson();
    }
    map['ledgerType'] = _ledgerType;
    map['totalDebit'] = _totalDebit;
    map['totalCredit'] = _totalCredit;
    map['balance'] = _balance;
    if (_entries != null) {
      map['entries'] = _entries?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// date : "2026-05-01"
/// invoiceNo : "jkjj88"
/// particular : "CASH"
/// debit : 0
/// credit : 789.99
/// runningBalance : 789.99

class Entries {
  Entries({
      String? date, 
      String? invoiceNo, 
      String? particular, 
      num? debit, 
      num? credit, 
      num? runningBalance,}){
    _date = date;
    _invoiceNo = invoiceNo;
    _particular = particular;
    _debit = debit;
    _credit = credit;
    _runningBalance = runningBalance;
}

  Entries.fromJson(dynamic json) {
    _date = json['date'];
    _invoiceNo = json['invoiceNo'];
    _particular = json['particular'];
    _debit = json['debit'];
    _credit = json['credit'];
    _runningBalance = json['runningBalance'];
  }
  String? _date;
  String? _invoiceNo;
  String? _particular;
  num? _debit;
  num? _credit;
  num? _runningBalance;
Entries copyWith({  String? date,
  String? invoiceNo,
  String? particular,
  num? debit,
  num? credit,
  num? runningBalance,
}) => Entries(  date: date ?? _date,
  invoiceNo: invoiceNo ?? _invoiceNo,
  particular: particular ?? _particular,
  debit: debit ?? _debit,
  credit: credit ?? _credit,
  runningBalance: runningBalance ?? _runningBalance,
);
  String? get date => _date;
  String? get invoiceNo => _invoiceNo;
  String? get particular => _particular;
  num? get debit => _debit;
  num? get credit => _credit;
  num? get runningBalance => _runningBalance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['date'] = _date;
    map['invoiceNo'] = _invoiceNo;
    map['particular'] = _particular;
    map['debit'] = _debit;
    map['credit'] = _credit;
    map['runningBalance'] = _runningBalance;
    return map;
  }

}

/// id : 2033
/// name : "ABCD Traders Update checking"
/// email : null
/// phone : null
/// gstNo : null
/// address : ""

class Party {
  Party({
      num? id, 
      String? name, 
      dynamic email, 
      dynamic phone, 
      dynamic gstNo, 
      String? address,}){
    _id = id;
    _name = name;
    _email = email;
    _phone = phone;
    _gstNo = gstNo;
    _address = address;
}

  Party.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _email = json['email'];
    _phone = json['phone'];
    _gstNo = json['gstNo'];
    _address = json['address'];
  }
  num? _id;
  String? _name;
  dynamic _email;
  dynamic _phone;
  dynamic _gstNo;
  String? _address;
Party copyWith({  num? id,
  String? name,
  dynamic email,
  dynamic phone,
  dynamic gstNo,
  String? address,
}) => Party(  id: id ?? _id,
  name: name ?? _name,
  email: email ?? _email,
  phone: phone ?? _phone,
  gstNo: gstNo ?? _gstNo,
  address: address ?? _address,
);
  num? get id => _id;
  String? get name => _name;
  dynamic get email => _email;
  dynamic get phone => _phone;
  dynamic get gstNo => _gstNo;
  String? get address => _address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['phone'] = _phone;
    map['gstNo'] = _gstNo;
    map['address'] = _address;
    return map;
  }

}