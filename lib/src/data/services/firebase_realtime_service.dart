import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseDatabaseService {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://studytogether-32111-default-rtdb.asia-southeast1.firebasedatabase.app/",
  );

  void checkConection() {
    DatabaseReference connectedRef = database.ref(".info/connected");
    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        print("✅ Firebase Realtime Database đã kết nối!");
      } else {
        print("❌ Chưa kết nối với Firebase Realtime Database.");
      }
    });
  }

  Future<Map<dynamic, dynamic>?> getData(String path) async {
    try {
      DatabaseReference ref = database.ref(path);
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        return snapshot.value as Map<dynamic, dynamic>;
      } else {
        print("Not data");
      }
    } catch (e) {
      print("$e");
      rethrow;
    }
    return null;
  }

  Stream<DatabaseEvent> listenToData(String path) {
    DatabaseReference ref = database.ref(path);
    return ref.onValue;
  }

  Future<void> updateValue(String path, String key, dynamic value) async {
    try {
      DatabaseReference ref = database.ref(path);
      await ref.update({key: value});
    } catch (e) {
      print("$e");
      rethrow;
    }
  }

  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    Map<String, Object?>? dataUpdate,
  }) async {
    try {
      DatabaseReference ref = database.ref(path);
      await ref.set(data);
      // ref.onDisconnect().update(dataUpdate!);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      DatabaseReference ref = database.ref(path);
      await ref.update(data);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> monitorConnection(void Function(DatabaseEvent)? onData) async {
    DatabaseReference connectionRef = database.ref(".info/connected");
    connectionRef.onValue.listen(onData);
  }
}

final firebaseDatabaseServiceProvider = Provider<FirebaseDatabaseService>(
  (ref) => FirebaseDatabaseService(),
);
