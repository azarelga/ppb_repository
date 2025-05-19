# Assignment 3: Firebase + Awesome Notifications

https://github.com/user-attachments/assets/61ace24d-86e7-4f72-ba56-680afad364ff
## Daftar Isi

1. [Pendahuluan](#pendahuluan)
2. [Migrasi dari SQLite ke Firebase](#migrasi-dari-sqlite-ke-firebase)
    - [Langkah 1: Hapus Dependensi SQLite](#langkah-1-hapus-dependensi-sqlite)
    - [Langkah 2: Tambahkan Dependensi Firebase](#langkah-2-tambahkan-dependensi-firebase)
    - [Langkah 3: Perbarui Logika Akses Data](#langkah-3-perbarui-logika-akses-data)
    - [Langkah 4: Tambah Fitur Autentikasi](#langkah-4-tambah-fitur-autentikasi)
    - [Langkah 5: Perbarui Kode Inisialisasi](#langkah-5-perbarui-kode-inisialisasi)
3. [Integrasi Awesome Notifications](#integrasi-awesome-notifications)
    - [Langkah 1: Tambahkan Dependensi Awesome Notifications](#langkah-1-tambahkan-dependensi-awesome-notifications)
    - [Langkah 2: Inisialisasi Awesome Notifications](#langkah-2-inisialisasi-awesome-notifications)
    - [Langkah 3: Memicu Notifikasi](#langkah-3-memicu-notifikasi)
4. [Ringkasan Perubahan](#ringkasan-perubahan)

---

## Pendahuluan

Panduan ini menjelaskan cara migrasi aplikasi dari penggunaan database lokal SQLite ke Firebase untuk penyimpanan dan pengelolaan data. Selain itu, panduan ini juga membahas integrasi paket Awesome Notifications untuk meningkatkan keterlibatan pengguna melalui notifikasi.

## Migrasi dari SQLite ke Firebase

### Langkah 1: Hapus Dependensi SQLite

- Hapus semua modul yang berhubungan dengan SQLite (`sqflite`, `path_provider`).
- Refactor kode yang menginisialisasi atau berinteraksi dengan database SQLite.

### Langkah 2: Tambahkan Dependensi Firebase

- Tambahkan paket Firebase ke `pubspec.yaml` aplikasi (`firebase_core`, `cloud_firestore`, `firebase_auth`).
- Jalankan `flutter pub get` untuk menginstal dependensi baru.

### Langkah 3: Perbarui Logika Akses Data

- Semua kode akses data yang sebelumnya menggunakan SQLite telah direfaktor untuk menggunakan Firestore dari Firebase. <br>
  Dari:
  ```dart
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  ```
  
  Menjadi: 
  ``` dart
  FirebaseService._init();
  static final FirebaseService instance = FirebaseService._init();
  
  final CollectionReference _transactionsCollection = 
      FirebaseFirestore.instance.collection('transactions');
  ```
  
- Pernyataan SQL seperti `SELECT`, `INSERT`, dan `UPDATE` diganti dengan pemanggilan metode Firestore seperti `collection()`, `doc()`, `get()`, `update()`, `add()`, dan `delete()`.
  <br>Dari:
  ```Dart
  Future<void> insertTransaction(app_model.Transaction transaction) async {
    final db = await instance.database;
    await db.insert(
      app_model.tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  ```
  <br>Menjadi:
  ```dart
  Future<void> insertTransaction(model.Transaction transaction) async {
    await _transactionsCollection.add({
      titleField: transaction.title,
      amountField: transaction.amount,
      dateField: transaction.date.toIso8601String(),
      typeField: transaction.type.toString().split('.').last,
    });
  }
  ```
- Model data diperbarui agar mendukung serialisasi/deserialisasi ke format dokumen Firestore (misal: menggunakan `fromMap` dan `toMap`).
  
### Langkah 4: Tambah Fitur Autentikasi
- Tambahkan halaman `login_page.dart`
```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (error != null) ...[
              Text(error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 8),
            ],
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: signIn, child: Text('Sign In')),
            TextButton(onPressed: register, child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
```
- Tambahkan kolom UID pada tabel `Transaction` untuk menambahkan relasi antara user dan data transaksi pada seluruh operasi CRUD Transaksi
```dart
Future<void> insertTransaction(
    model.Transaction transaction, {
    required String uid, // Wajibkan parameter User ID
  }) async {
    await _transactionsCollection.add({
      'uid': uid, // Tambah kolom UID
      titleField: transaction.title,
      amountField: transaction.amount,
      dateField: transaction.date.toIso8601String(),
      typeField: transaction.type.toString().split('.').last,
    });
}
```
Saat pemanggilan method tersebut, User ID dapat diambil dengan modul `FirebaseAuth`:
```dart
await _firebaseService.insertTransaction(
  newTransaction,
  uid: FirebaseAuth.instance.currentUser!.uid,
);
```
  
### Langkah 5: Perbarui Kode Inisialisasi

- Firebase diinisialisasi pada titik masuk utama aplikasi, misal di `main.dart`.
- Inisialisasi dilakukan secara asinkron sebelum aplikasi dijalankan, menggunakan `WidgetsFlutterBinding.ensureInitialized()` dan `Firebase.initializeApp()`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```
---

## Integrasi Awesome Notifications

### Langkah 1: Tambahkan Dependensi Awesome Notifications

- Tambahkan `awesome_notifications` ke `pubspec.yaml` aplikasi.
- Jalankan `flutter pub get` untuk menginstal paket.

### Langkah 2: Inisialisasi Awesome Notifications

- Inisialisasi Awesome Notifications di kode startup aplikasi.
  ```dart
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
  // ...
  ```
  
  Method inisialisasi `NotificationServis` dapat dipanggil pada `main.dart`:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize notifications
    await NotificationService().initialize();
    
    runApp(MyApp());
  }
  ```
- Tambahkan service notifikasi yang berkaitan
  ```dart
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
  // ...
  ```
- Minta izin notifikasi dari pengguna jika diperlukan.
  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android">
      <!-- The INTERNET permission is required for development. Specifically,
           the Flutter tool needs it to communicate with the running application
           to allow setting breakpoints, to provide hot reload, etc.
      -->
      <uses-permission android:name="android.permission.INTERNET"/>
      <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
      <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
      <uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>
  </manifest>
  ```

### Langkah 3: Memicu Notifikasi

- Gunakan API Awesome Notifications untuk membuat dan menampilkan notifikasi berdasarkan event aplikasi (misal: perubahan data, pengingat).
```dart
// Notifikasi Penambahan Transaksi
_notificationService.showAddTransactionNotification(newTransaction);
// ...
// Notifikasi Update
_notificationService.showEditTransactionNotification(updatedTx);
```

## Ringkasan Perubahan

- **Menghapus semua kode dan dependensi yang berkaitan dengan SQLite.**
- **Menambahkan dependensi Firebase dan refaktor akses data menggunakan Firestore.**
- **Inisialisasi Firebase pada startup aplikasi.**
- **Modifikasi model dan akses database**
- **Integrasi Awesome Notifications.**

Dengan mengikuti langkah-langkah ini, aplikasi akan beralih dari penggunaan database lokal SQLite ke Firestore berbasis cloud dari Firebase, serta mendapatkan manfaat dari fitur notifikasi yang lebih baik melalui Awesome Notifications.
