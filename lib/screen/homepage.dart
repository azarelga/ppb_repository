import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ppb_repository/model/transaction.model.dart';
import 'package:ppb_repository/widgets/transaction_form.dart';
import 'package:ppb_repository/widgets/transaction_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaction> _transactions = [];

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  Transaction? _editingTransaction;

  // Calculate net worth
  double get _netWorth {
    return _transactions.fold(0, (sum, transaction) {
      return transaction.type == TransactionType.income
          ? sum + transaction.amount
          : sum - transaction.amount;
    });
  }

  // Show Input Transaction Modal
  void _showAddTransactionSheet({Transaction? transaction}) {
    // If editing, populate fields
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _selectedType = transaction.type;
      _editingTransaction = transaction;
    } else {
      _titleController.clear();
      _amountController.clear();
      _selectedType = TransactionType.expense;
      _editingTransaction = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return TransactionForm(
              titleController: _titleController,
              amountController: _amountController,
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setModalState(() {
                  _selectedType = type;
                });
              },
              onSubmit: _submitTransaction,
              onCancel: () => Navigator.of(context).pop(),
              isEditing: _editingTransaction != null,
            );
          },
        );
      },
    );
  }

  // Create transaction and update _transaction list
  void _submitTransaction() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    if (_editingTransaction == null) {
      // Create new transaction
      setState(() {
        _transactions.add(
          Transaction(
            id: DateTime.now().toString(),
            title: enteredTitle,
            amount: enteredAmount,
            date: DateTime.now(),
            type: _selectedType,
          ),
        );
      });
    } else {
      // Update existing transaction
      setState(() {
        _editingTransaction!.title = enteredTitle;
        _editingTransaction!.amount = enteredAmount;
        _editingTransaction!.type = _selectedType;
      });
    }

    Navigator.of(context).pop();
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Azarel\'s Expense Tracker App'),
      ),
      body: Column(
        // Net Worth
        children: [
          Card(
            margin: EdgeInsets.all(20),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Jumlah saldo kamu segini:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currencyFormat.format(_netWorth),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _netWorth >= 0 ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Transaction List header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical:16),
            child: Row(
              children: [
                Text(
                  'List Transaksi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: _transactions.isEmpty // If empty,
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Diisi yuk transaksinya!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder( // If its not empty,
              itemCount: _transactions.length,
              itemBuilder: (ctx, index) {
                final tx = _transactions[index];
                return TransactionItem(
                  transaction: tx,
                  currencyFormat: currencyFormat,
                  onDelete: () => _deleteTransaction(tx.id),
                  onEdit: () => _showAddTransactionSheet(transaction: tx),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(),
        child: Icon(Icons.add),
      ),
    );
  }
}
