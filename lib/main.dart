import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azarel\'s Budgeting App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BudgetPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Transaction model class
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

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
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
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _editingTransaction == null ? 'Tambah Transaksi' : 'Ubah Transaksi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah (Rp)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Tipe: '),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Pemasukan'),
                          selected: _selectedType == TransactionType.income,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _selectedType = TransactionType.income;
                              });
                            }
                          },
                          selectedColor: Colors.green[100],
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Pengeluaran'),
                          selected: _selectedType == TransactionType.expense,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                _selectedType = TransactionType.expense;
                              });
                            }
                          },
                          selectedColor: Colors.red[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('BATAL'),
                        ),
                        ElevatedButton(
                          onPressed: _submitTransaction,
                          child: Text(_editingTransaction == null ? 'TAMBAH' : 'UPDATE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
        title: Text('Azarel\'s Budget App'),
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

// Custom Stateless Widgets
class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final NumberFormat currencyFormat;
  final Function onDelete;
  final Function onEdit;

  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.currencyFormat,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: () => onEdit(),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.type == TransactionType.income
                  ? Colors.green[100]
                  : Colors.red[100],
              radius: 15,
              child: Icon(
                transaction.type == TransactionType.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.type == TransactionType.income
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            title: Text(
              transaction.title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
            subtitle: Text(
                DateFormat('dd MMM yyyy').format(transaction.date),
                style: TextStyle(fontSize: 12.0)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currencyFormat.format(transaction.amount),
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: transaction.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                SizedBox(width: 1),
                IconButton(
                  icon: Icon(Icons.delete, size: 20),
                  onPressed: () => onDelete(),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
    );
  }
}