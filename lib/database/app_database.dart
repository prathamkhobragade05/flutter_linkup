import 'package:drift/drift.dart';

import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

                                                                                //------table Registered Users
class DBUsers extends Table {
  IntColumn get userId => integer().autoIncrement()();
  TextColumn get userEmail => text().unique()();
  TextColumn get userName => text()();
  TextColumn get userPassword => text()();
  TextColumn get profileImg => text().nullable()();
}
                                                                                //-table---------messages
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get senderId => text()();
  TextColumn get receiverId => text()();
  TextColumn get message => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [DBUsers,Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;
                                                                                //--------is email already exists
  Future<DBUser?> isEmailRegistered(String email) {
    final query = select(dBUsers)..where((t) => t.userEmail.equals(email));
    // final user=query.getSingleOrNull();
    return query.getSingleOrNull();
  }
                                                                                //---------get all users on home screen
  Stream<List<DBUser>> getAllUsers() {
    return select(dBUsers).watch();
  }

  Stream<DBUser> getSingleUser(int userId) {
    return (select(dBUsers)
      ..where((tbl) => tbl.userId.equals(userId)))
        .watchSingle();
  }
                                                                                //----get chatting messages
  Stream<List<Message>> watchChatMessages(String user1, String user2) {
    return (select(messages)
      ..where((tbl) =>
      (tbl.senderId.equals(user1) & tbl.receiverId.equals(user2)) |
      (tbl.senderId.equals(user2) & tbl.receiverId.equals(user1)))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
    ).watch();
  }
                                                                                //----Insert message
  Future<void> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);
                                                                                //----Insert or updateImage Path
  Future<void> updateProfileImage(int userId, String? imagePath) async {
    await (update(dBUsers)
      ..where((tbl) => tbl.userId.equals(userId)))
        .write(DBUsersCompanion(
      profileImg: Value(imagePath),
    ));
  }
                                                                                //--------------remove profile
  Future<bool> deleteImage(int userId) async {
    try{
      await(delete((dBUsers))
          ..where((tbl) => tbl.userId.equals(userId))).go();
      return true;
    }catch(e){
      return false;
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'linkup.db'));
    return NativeDatabase(file);
  });
}

