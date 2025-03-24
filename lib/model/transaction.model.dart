class Transaction {
  final String id;
  String title;
  double amount;
  DateTime date;
  TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

enum TransactionType { income, expense }
