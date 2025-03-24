import 'package:flutter/material.dart';
import 'package:ppb_repository/model/transaction.model.dart';
import 'package:intl/intl.dart';

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
