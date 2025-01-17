import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('Message')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text().nullable()();
  TextColumn get message => text().nullable()();
  TextColumn get messageId => text().nullable()();
  IntColumn get jobId => integer().nullable()();
  DateTimeColumn get retrieveDate => dateTime().nullable()();
  DateTimeColumn get sentDate => dateTime().nullable()();
  DateTimeColumn get deliveredDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Messages])
class AppDatabase extends _$AppDatabase {

  AppDatabase() : super(_openConnection());

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    });
  }

  // Ajouter une méthode pour fermer la base
  @override
  Future<void> close() async {
    await close();
  }

  // Définition de la méthode watchAllSms()
  Stream<List<Message>> watchAllMessage() {
    return select(messages).watch();
  }

  @override
  int get schemaVersion => 2;

  Future<int> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  Future<List<Message>> getAllMessages() => select(messages).get();

  Future<void> updateMessage(int id, MessagesCompanion updatedMessage) {
    return (update(messages)..where((tbl) => tbl.id.equals(id))).write(updatedMessage);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll(); // Créer toutes les tables
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Logique de migration de la version 1 à la version 2 (si nécessaire)
        // Par exemple: await m.addColumn(messages, messages.nouvelleColonne);
      }
    },
  );
}
