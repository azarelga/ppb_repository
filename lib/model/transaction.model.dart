const String tableName = 'transactions';

const String idField = '_id';
const String titleField = 'title';
const String amountField = 'amount';
const String dateField = 'date';
const String typeField = 'type';

const List<String> transactionFields = [
  idField,
  titleField,
  amountField,
  dateField,
  typeField,
];

class Transaction {
  final String? id;
  String title;
  double amount;
  DateTime date;
  TransactionType type;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json[idField],
      title: json[titleField],
      amount: json[amountField] is int 
          ? (json[amountField] as int).toDouble() 
          : json[amountField],
      date: DateTime.parse(json[dateField]),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json[typeField]}',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idField: id,
      titleField: title,
      amountField: amount,
      dateField: date.toIso8601String(),
      typeField: type.toString().split('.').last,
    };
  }

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}

enum TransactionType { income, expense }
