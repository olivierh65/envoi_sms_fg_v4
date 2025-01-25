import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import 'background_service.dart';
// Import pour ValueNotifier

part 'database.g.dart';

final ValueNotifier<Stream<List<Message>>> messageStreamNotifier =
ValueNotifier<Stream<List<Message>>>(Stream.empty()); // Initialiser avec un Stream vide

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
  late final BackgroundServiceManager _backgroundServiceManager; // Ajouter une variable d'instance

  AppDatabase() : super(_openConnection()) {
    _backgroundServiceManager = BackgroundServiceManager(); // Initialiser la variable d'instance
  }


  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase(file);
    });
  }

  void _updateMessageStream() async {
    final messages = await getAllMessages(); // Récupérer les messages de la base
    _backgroundServiceManager.messageStreamController.add(messages); // Mettre à jour le StreamController
  }

  // Ajouter une méthode pour fermer la base
  @override
  Future<void> close() async {
    await close();
  }

  // Définition de la méthode watchAllSms()
  Stream<List<Message>> watchAllMessage() {
    return select(messages).watch();
    // return (select(messages)..orderBy([(t) => OrderingTerm(expression: t.id)])).watch();
  }

  @override
  int get schemaVersion => 3;

  Future<int> insertMessage(MessagesCompanion message) async {
    final result = into(messages).insert(message);
    _updateMessageStream(); // Mettre à jour le StreamController
    return result;
  }

  Future<List<Message>> getAllMessages() => select(messages).get();

  Future<void> updateMessage(int id, MessagesCompanion updatedMessage) {

    final result =  (update(messages)..where((tbl) => tbl.id.equals(id)))
        .write(updatedMessage);
    _updateMessageStream(); // Mettre à jour le StreamController
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
    _updateMessageStream(); // Mettre à jour le StreamController

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
