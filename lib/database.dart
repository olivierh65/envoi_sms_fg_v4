import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

@DataClassName('Message')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get destinataire => text()();
  TextColumn get message => text()();
  TextColumn get messageId => text()();
  IntColumn get jobId => integer()();
  DateTimeColumn get retrieveDate => dateTime().nullable()();
  DateTimeColumn get sentDate => dateTime().nullable()();
  DateTimeColumn get deliveredDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Messages])
class AppDatabase extends _$AppDatabase {
  final NativeDatabase _nativeDatabase;

  AppDatabase()
      : _nativeDatabase = NativeDatabase.memory(), // Ou NativeDatabase(File(...)) si vous sauvegardez dans un fichier
        super(NativeDatabase.memory());

  // Ajouter une méthode pour fermer la base
  @override
  Future<void> close() async {
    await _nativeDatabase.close();
  }

  @override
  int get schemaVersion => 1;

  Future<int> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  Future<List<Message>> getAllMessages() => select(messages).get();

  Future<void> updateMessage(int id, MessagesCompanion updatedMessage) {
    return (update(messages)..where((tbl) => tbl.id.equals(id))).write(updatedMessage);
  }
}
