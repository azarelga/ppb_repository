import 'package:flutter/material.dart';
import 'package:expense_tracker/model/transaction.model.dart';

class TransactionForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool isEditing;

  const TransactionForm({
    Key? key,
    required this.titleController,
    required this.amountController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onSubmit,
    required this.onCancel,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              isEditing ? 'Ubah Transaksi' : 'Tambah Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
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
                  selected: selectedType == TransactionType.income,
                  onSelected: (selected) {
                    if (selected) {
                      onTypeChanged(TransactionType.income);
                    }
                  },
                  selectedColor: Colors.green[100],
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Pengeluaran'),
                  selected: selectedType == TransactionType.expense,
                  onSelected: (selected) {
                    if (selected) {
                      onTypeChanged(TransactionType.expense);
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
                TextButton(onPressed: onCancel, child: Text('BATAL')),
                ElevatedButton(
                  onPressed: onSubmit,
                  child: Text(isEditing ? 'UPDATE' : 'TAMBAH'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

