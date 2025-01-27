import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


// Import pour ValueNotifier

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

  @override
  List<String> get customConstraints => [
        'UNIQUE(message_id, job_id)', // Contrainte d'unicité sur le couple
      ];

}

@DriftDatabase(tables: [Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection()) {
    debugPrint("Constructeur AppDatabase");
    debugPrint("StackTrace actuel : ${StackTrace.current}");
  }

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

  Stream<List<Map<String, dynamic>>> watchAllMessages() async* {
    var messagesList = select(messages)
      ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])
      ..get();

    await for (var messageList in messagesList.watch()) {
      // Sérialisation des messages avant de les émettre
      var serializedMessages = messageList.map((msg) {
        // Sérialiser chaque Message en JSON
        return msg.toJson();
      }).toList();
      yield serializedMessages; // Émet les messages sérialisés
    }
  }

  Stream<List<Message>> ___watchAllMessages() {
    var messagesList = select(messages)
      ..orderBy(
          [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)])
      ..get();
    return messagesList.watch();
  }

  Stream<List<Message>> __watchAllMessages() {
    var data = customSelect(
      'SELECT id, job_id, retrieve_date, sent_date, delivered_date FROM messages ORDER BY date DESC',
      readsFrom: {messages}, // Table explicitement observée
    ).watch().map((rows) {
      return rows.map((row) {
        return Message(
          id: row.read<int>('id'),
          jobId: row.read<int>('job_id'),
          retrieveDate: row.read<DateTime>('retrieve_date'),
          sentDate: row.read<DateTime>('sent_date'),
          deliveredDate: row.read<DateTime>('delivered_date'),
        );
      }).toList();
    });
    return data;
  }

  @override
  int get schemaVersion => 3;

  Future<int> insertMessage(MessagesCompanion message) async {
    final result = into(messages).insert(message);
    return result;
  }

  Future<List<Message>> getAllMessages() => select(messages).get();

  Future<void> updateMessage(int id, MessagesCompanion updatedMessage) {
    final result = (update(messages)..where((tbl) => tbl.id.equals(id)))
        .write(updatedMessage);
    return result;
  }

  Future<List<Message>> getMessagesNotSent() async {
    final query = select(messages);
    query.where((tbl) => tbl.sentDate.isNull());

    final result = await query.get();
    return result;
  }

  Future<void> updateMessageSent(int id, int? jobId) {
    var updatedMessage = MessagesCompanion(
      sentDate: Value(DateTime.now()),
    );
    final updt = update(messages);
    updt.where((tbl) => tbl.id.equals(id));
    if (jobId != null) {
      updt.where((tbl) => tbl.jobId.equals(jobId));
    }

    return updt.write(updatedMessage);
  }

  Future<int> isMessageExist(String? messageId, int? jobId) async {
    final query = select(messages);
    if (messageId != null) {
      query.where((tbl) => tbl.messageId.equals(messageId));
    }
    if (jobId != null) {
      query.where((tbl) => tbl.jobId.equals(jobId));
    }

    final result = await query.get();
    if (result.isEmpty) {
      return 0; // Aucun message trouvé
    } else {
      return result.length;
    }
  }


  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll(); // Créer toutes les tables
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from <= 1 && to >= 2) {
            // Logique de migration de la version 1 à la version 2 (si nécessaire)
            // Par exemple: await m.addColumn(messages, messages.nouvelleColonne);
            await m.createAll(); // Créer toutes les tables
          }
        },
      );
}
