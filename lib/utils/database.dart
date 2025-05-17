import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/transaction.model.dart' as model;
import 'package:expense_tracker/model/transaction.model.dart';

class FirebaseService {
  FirebaseService._init();
  static final FirebaseService instance = FirebaseService._init();

  final CollectionReference _transactionsCollection = FirebaseFirestore.instance
      .collection('transactions');

  // Insert a new transaction
  Future<void> insertTransaction(
    model.Transaction transaction, {
    required String uid,
  }) async {
    await _transactionsCollection.add({
      'uid': uid,
      titleField: transaction.title,
      amountField: transaction.amount,
      dateField: transaction.date.toIso8601String(),
      typeField: transaction.type.toString().split('.').last,
    });
  }

  // Update existing transaction
  Future<void> updateTransaction(
    model.Transaction transaction, {
    required String uid,
  }) async {
    if (transaction.id == null) return;

    await _transactionsCollection.doc(transaction.id).update({
      'uid': uid,
      titleField: transaction.title,
      amountField: transaction.amount,
      dateField: transaction.date.toIso8601String(),
      typeField: transaction.type.toString().split('.').last,
    });
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }

  // Get all transactions
  Stream<List<model.Transaction>> getAllTransactionsStream({
    required String uid,
  }) {
    return _transactionsCollection.where('uid', isEqualTo: uid).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return model.Transaction(
            id: doc.id,
            title: data[titleField],
            amount:
                data[amountField] is int
                    ? (data[amountField] as int).toDouble()
                    : data[amountField],
            date: DateTime.parse(data[dateField]),
            type: TransactionType.values.firstWhere(
              (e) => e.toString() == 'TransactionType.${data[typeField]}',
            ),
          );
        }).toList();
      },
    );
  }

  // Get a list of transactions (one-time fetch)
  Future<List<model.Transaction>> getAllTransactions({
    required String uid,
  }) async {
    final snapshot =
        await _transactionsCollection.where('uid', isEqualTo: uid).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return model.Transaction(
        id: doc.id,
        title: data[titleField],
        amount:
            data[amountField] is int
                ? (data[amountField] as int).toDouble()
                : data[amountField],
        date: DateTime.parse(data[dateField]),
        type: TransactionType.values.firstWhere(
          (e) => e.toString() == 'TransactionType.${data[typeField]}',
        ),
      );
    }).toList();
  }
}
