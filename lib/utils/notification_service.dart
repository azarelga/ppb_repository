import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/model/transaction.model.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'transaction_channel',
        channelName: 'Transaction Notifications',
        channelDescription: 'Notifications for transaction activities',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ], debug: true);

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> showAddTransactionNotification(Transaction transaction) async {
    final String typeText =
        transaction.type == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'transaction_channel',
        title: '$typeText Baru Ditambahkan',
        body:
            '${transaction.title}: ${currencyFormat.format(transaction.amount)}',
        notificationLayout: NotificationLayout.Default,
        color:
            transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
      ),
    );
  }

  Future<void> showEditTransactionNotification(Transaction transaction) async {
    final String typeText =
        transaction.type == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'transaction_channel',
        title: '$typeText Diperbarui',
        body:
            '${transaction.title}: ${currencyFormat.format(transaction.amount)}',
        notificationLayout: NotificationLayout.Default,
        color:
            transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
      ),
    );
  }

  Future<void> showDeleteTransactionNotification(String title) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'transaction_channel',
        title: 'Transaksi Dihapus',
        body: 'Transaksi "$title" telah dihapus',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> showBalanceNotification(double amount) async {
    final color = amount >= 0 ? Colors.green : Colors.red;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'transaction_channel',
        title: 'Saldo Saat Ini',
        body: 'Saldo kamu: ${currencyFormat.format(amount)}',
        notificationLayout: NotificationLayout.Default,
        color: color,
      ),
    );
  }
}
