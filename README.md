# Assignment 2: Persistent Data with SQFLite

https://github.com/user-attachments/assets/b8c4cf2b-1037-4355-98e0-dae952d0c6c2

<!--toc:start-->
- [Assignment 2: Persistent Data with SQFLite](#assignment-2-persistent-data-with-sqflite)
  - [Step 1: Instalasi Dependencies](#step-1-instalasi-dependencies)
  - [Step 2: Modifikasi Model](#step-2-modifikasi-model)
    - [Menambahkan Variabel](#menambahkan-variabel)
    - [Menambahkan Method Class `Transaction`](#menambahkan-method-class-transaction)
  - [Step 3: Inisialisasi Database](#step-3-inisialisasi-database)
    - [Import Packages](#import-packages)
    - [Inisialisasi Class](#inisialisasi-class)
    - [Method CRUD Database](#method-crud-database)
  - [Step 4: Modifikasi Callback pada `main` dan Screen](#step-4-modifikasi-callback-pada-main-dan-screen)
    - [Rombak Method `homepage.dart`](#rombak-method-homepagedart)
<!--toc:end-->
Pada tugas ini, saya akan menambahkan fitur untuk menyimpan data yang telah disimpan pada aplikasi secara lokal (instead of di dalam variabel List) menggunakan **SQFlite**.

## Step 1: Instalasi Dependencies

First and foremost, mari kita menginstall `pub` untuk SQFlite melalui `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  intl: ^0.18.0
  sqflite: 2.4.2 # Tambahkan line ini
  path: 1.9.1 # Dan juga line ini
```

Setelah menambahkan kedua dependencies tersebut, kita dapat menjalankan:

```bash
flutter pub get
```

> Note: Pada step ini, saya mengalami masalah mismatch versi Android NDK yang menyebabkan masalah baru saat penggunaan SQFlite nantinya. Oleh karena itu, perlu diperhatikan versi Android NDK sebelum memulai project ini. Apabila masalah yang dihadapi sama seperti saya, bisa cek lebih lanjut pada <https://stackoverflow.com/questions/77228813/where-is-defined-flutter-ndkversion-in-build-gradle>

## Step 2: Modifikasi Model

> Penambahan detail - detail model saya ikuti dari tutorial [Youtube](https://youtu.be/bihC6ou8FqQ?si=hRiBUFfkq391xDn9)

Sebelum kita membuat utilities untuk membuat\mengakses local database, kita perlu menambahkan beberapa method dan variabel krusial untuk model yang digunakan pada aplikasi. Kebetulan, saya hanya menggunakan satu model saja, yakni Transaksi saja. Modifikasi model terdapat pada `ppb_repository/lib/model/transaction.model.dart`

### Menambahkan Variabel

```dart
const String tableName = 'transaction_table';

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

const String boolType = "BOOLEAN NOT NULL";
const String idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
const String textType = "TEXT NOT NULL";
const String doubleType = "DOUBLE NOT NULL";
const String integerType = "INTEGER NOT NULL";
```

Variabel - variabel di atas merepresentasikan keyword - keyword yang diperlukan saat pembuatan tabel baru (bila belum dibuat) pada SQLite. Praktek ini saya ambil dari video YouTube yang tertera di atas.

### Menambahkan Method Class `Transaction`

Kemudian pada class `Transaction`, kita menambahkan 2 method:

1. `fromJSON()`:  untuk mengembalikan objek `Transaction` dari JSON yang berisi detail mengenai `Transaction` (Database → JSON → Objek Transaction).

    ```dart
      static Transaction fromJson(Map<String, dynamic> json) {
        return Transaction(
          id: json[idField] as int?,
          title: json[titleField],
          amount: json[amountField],
          date: DateTime.parse(json[dateField]),
          type: TransactionType.values.firstWhere(
            (e) => e.toString() == 'TransactionType.${json[typeField]}',
          ),
        );
      }
    ```

2. `toMap()`: untuk mengkonversi objek `Transaction` menjadi human-readable JSON (Objek Transaction → JSON → Database)

    ```dart
      Map<String, dynamic> toMap() {
        return {
          idField: id,
          titleField: title,
          amountField: amount,
          dateField: date.toIso8601String(),
          typeField: type.toString().split('.').last,
        };
      }
    ```

3. `copyWith()`: membuat salinan baru dari objek `Transaction` dengan mengganti nilai properti tertentu jika disediakan, atau menggunakan nilai lama jika tidak. Berguna untuk operasi update nantinya.

    ```dart
      Transaction copyWith({
        int? id,
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
    ```

## Step 3: Inisialisasi Database

Class yang akan digunakan untuk interaksi antara aplikasi dan database saya letakkan pada file baru `ppb_repository/lib/utils/database.dart`.

### Import Packages

Pertama - tama, kita dapat mengimport modul - modul SQFlite, path, dan model.

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ppb_repository/model/transaction.model.dart' as app_model;
```

> Alias `app_model` digunakan karena adanya bentrok class `Transaction` antara modul SQFlite dan model saya.
>

### Inisialisasi Class

Selanjutnya, kita bisa langsung menginstansiasi kelas `Database` untuk mengelola akses ke database (berdasarkan tutorial YouTube):

```dart
class AppDatabase {
  AppDatabase._init();

  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(fileName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

...
```

> Database `version: 2` pada repository saya dikarenakan kesalahan query `CREATE TABLE` yang saya lakukan pada `version: 1`.

- `instance`: Objek statis AppDatabase sebagai titik akses tunggal ke database.
- `_database`: Variabel statis bertipe `Database?` yang menampung koneksi database.
- `database (getter)`: Metode async yang mengembalikan instance `Database`; jika null, memanggil `_initDB`.
- `_initDB(String fileName)`: Metode untuk menentukan lokasi file database dan membukanya dengan `openDatabase`.

### Method CRUD Database

1. `_createDB(Database db, int version)`: Callback `onCreate` yang mengeksekusi perintah `CREATE TABLE` sesuai skema yang sudah kita definisikan pada model.

    ```dart
    Future _createDB(Database db, int version) async {
      await db.execute('''
        CREATE TABLE ${app_model.tableName}(
          ${app_model.idField} ${app_model.idType},
          ${app_model.titleField} ${app_model.textType},
          ${app_model.amountField} ${app_model.doubleType},
          ${app_model.dateField} ${app_model.textType},
          ${app_model.typeField} ${app_model.textType}
        )
      ''');
    }
    ```

2. `insertTransaction(app_model.Transaction transaction)`: Menyisipkan baris baru ke tabel database dengan konflik diganti jika ada data sama.

    ```dart
    Future<void> insertTransaction(app_model.Transaction transaction) async {
      final db = await instance.database;
      await db.insert(
        app_model.tableName,
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    ```

3. `updateTransaction(app_model.Transaction transaction)`: Memperbarui baris di tabel database dengan kondisi `WHERE` mengacu ke `id`.

    ```dart
    Future<void> updateTransaction(app_model.Transaction transaction) async {
      final db = await instance.database;
      await db.update(
        app_model.tableName,
        transaction.toMap(),
        where: '${app_model.idField} = ?',
        whereArgs: [transaction.id],
      );
    }
    ```

4. `deleteTransaction(int id)`: Menghapus baris di tabel database berdasarkan `id`.

    ```dart
    Future<void> deleteTransaction(int id) async {
      final db = await instance.database;
      await db.delete(
        app_model.tableName,
        where: '${app_model.idField} = ?',
        whereArgs: [id],
      );
    }
    ```

5. `getAllTransactions()`: Mengembalikan seluruh `Transaction` yang ada pada database.

    ```dart
    Future<List<app_model.Transaction>> getAllTransactions() async {
      final db = await instance.database;
      final result = await db.query(app_model.tableName);
      return result.map((json) => app_model.Transaction.fromJson(json)).toList();
    }
    ```

## Step 4: Modifikasi Callback pada `main` dan Screen

Dengan utilities database yang telah kita buat dan model yang sudah kita ubah, kita dapat memodifikasi `main.dart` dan `homepage.dart` untuk menggunakan database. Method - method seperti `_submitTransaction()` dan `_deleteTransaction()` pada `homepage.dart` juga perlu dimodifikasi untuk menggunakan method - method yang telah kita buat pada `database.dart`.

### Rombak Method `homepage.dart`

1. `_submitTransaction()`: Method `SetState()` dapat kita ubah menjadi method database untuk menyimpan data ke dalam database, yakni `insertTransaction`. Apabila operasi yang dilakukan adalah update, kita dapat menggunakan method `updateTransaction`. Setelah operasi Create atau Update telah dilakukan, kita dapat me-refresh list transaksi dari database menggunakan method `_refreshTransactions()`

```dart
  Future<void> _submitTransaction() async {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    if (_editingTransaction == null) {
      // Create new transaction
      final newTransaction = Transaction(
        title: enteredTitle,
        amount: enteredAmount,
        date: DateTime.now(),
        type: _selectedType,
      );
      await AppDatabase.instance.insertTransaction(newTransaction);
    } else {
      // Update existing transaction
      final updatedTx = _editingTransaction!.copyWith(
        title: enteredTitle,
        amount: enteredAmount,
        type: _selectedType,
      );
      await AppDatabase.instance.updateTransaction(updatedTx);
    }

    // Refresh the list from database
    _refreshTransactions();

    Navigator.of(context).pop();
  }

```

2. `_refreshTransactions()`: Method ini digunakan untuk mengambil data dari database dan menyimpannya ke dalam list transaksi yang ada pada aplikasi. Kita dapat menggunakan method `getAllTransactions()` yang telah kita buat sebelumnya.

```dart
  Future<void> _refreshTransactions() async {
    final allTransactions = await AppDatabase.instance.getAllTransactions();
    setState(() {
      _transactions.clear();
      _transactions.addAll(allTransactions);
    });
  }
```

3. `_deleteTransaction():` Method ini digunakan untuk menghapus transaksi dari database. Kita dapat menggunakan method database `deleteTransaction()` yang telah kita buat sebelumnya.

```dart
  Future<void> _deleteTransaction(int id) async {
    await AppDatabase.instance.deleteTransaction(id);
    _refreshTransactions();
  }
```

### Cherry on Top pada `main.dart`

Yang terakhir, pada `main.dart` , kita dapat menginisialisasi database dengan memanggil `AppDatabase.instance.database` pada `main()`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database; // ensures DB is ready
  runApp(MyApp());
}
```
