class GetLedgerDetails {
  final bool? success;
  final String? message;
  final LedgerData? data;

  GetLedgerDetails({
    this.success,
    this.message,
    this.data,
  });

  factory GetLedgerDetails.fromJson(Map<String, dynamic> json) {
    return GetLedgerDetails(
      success: json['success'],
      message: json['message'],
      data:
      json['data'] != null ? LedgerData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }

  GetLedgerDetails copyWith({
    bool? success,
    String? message,
    LedgerData? data,
  }) {
    return GetLedgerDetails(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class LedgerData {
  final LedgerParty? party;
  final String? ledgerType;
  final num? totalDebit;
  final num? totalCredit;
  final num? balance;
  final List<LedgerEntry>? entries;

  LedgerData({
    this.party,
    this.ledgerType,
    this.totalDebit,
    this.totalCredit,
    this.balance,
    this.entries,
  });

  factory LedgerData.fromJson(Map<String, dynamic> json) {
    return LedgerData(
      party:
      json['party'] != null ? LedgerParty.fromJson(json['party']) : null,
      ledgerType: json['ledgerType'],
      totalDebit: json['totalDebit'],
      totalCredit: json['totalCredit'],
      balance: json['balance'],
      entries: json['entries'] != null
          ? (json['entries'] as List)
          .map((e) => LedgerEntry.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'party': party?.toJson(),
      'ledgerType': ledgerType,
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'balance': balance,
      'entries': entries?.map((e) => e.toJson()).toList(),
    };
  }

  LedgerData copyWith({
    LedgerParty? party,
    String? ledgerType,
    num? totalDebit,
    num? totalCredit,
    num? balance,
    List<LedgerEntry>? entries,
  }) {
    return LedgerData(
      party: party ?? this.party,
      ledgerType: ledgerType ?? this.ledgerType,
      totalDebit: totalDebit ?? this.totalDebit,
      totalCredit: totalCredit ?? this.totalCredit,
      balance: balance ?? this.balance,
      entries: entries ?? this.entries,
    );
  }
}

class LedgerEntry {
  final String? date;
  final String? invoiceNo;
  final String? particular;
  final num? debit;
  final num? credit;
  final num? runningBalance;

  LedgerEntry({
    this.date,
    this.invoiceNo,
    this.particular,
    this.debit,
    this.credit,
    this.runningBalance,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      date: json['date'],
      invoiceNo: json['invoiceNo'],
      particular: json['particular'],
      debit: json['debit'],
      credit: json['credit'],
      runningBalance: json['runningBalance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'invoiceNo': invoiceNo,
      'particular': particular,
      'debit': debit,
      'credit': credit,
      'runningBalance': runningBalance,
    };
  }

  LedgerEntry copyWith({
    String? date,
    String? invoiceNo,
    String? particular,
    num? debit,
    num? credit,
    num? runningBalance,
  }) {
    return LedgerEntry(
      date: date ?? this.date,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      particular: particular ?? this.particular,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      runningBalance: runningBalance ?? this.runningBalance,
    );
  }
}

class LedgerParty {
  final num? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? gstNo;
  final String? address;

  LedgerParty({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gstNo,
    this.address,
  });

  factory LedgerParty.fromJson(Map<String, dynamic> json) {
    return LedgerParty(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gstNo: json['gstNo'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gstNo': gstNo,
      'address': address,
    };
  }

  LedgerParty copyWith({
    num? id,
    String? name,
    String? email,
    String? phone,
    String? gstNo,
    String? address,
  }) {
    return LedgerParty(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gstNo: gstNo ?? this.gstNo,
      address: address ?? this.address,
    );
  }
}