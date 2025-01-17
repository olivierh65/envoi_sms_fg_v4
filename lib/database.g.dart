// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _destinataireMeta =
      const VerificationMeta('destinataire');
  @override
  late final GeneratedColumn<String> destinataire = GeneratedColumn<String>(
      'destinataire', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
      'job_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _retrieveDateMeta =
      const VerificationMeta('retrieveDate');
  @override
  late final GeneratedColumn<DateTime> retrieveDate = GeneratedColumn<DateTime>(
      'retrieve_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sentDateMeta =
      const VerificationMeta('sentDate');
  @override
  late final GeneratedColumn<DateTime> sentDate = GeneratedColumn<DateTime>(
      'sent_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deliveredDateMeta =
      const VerificationMeta('deliveredDate');
  @override
  late final GeneratedColumn<DateTime> deliveredDate =
      GeneratedColumn<DateTime>('delivered_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        destinataire,
        message,
        messageId,
        jobId,
        retrieveDate,
        sentDate,
        deliveredDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('destinataire')) {
      context.handle(
          _destinataireMeta,
          destinataire.isAcceptableOrUnknown(
              data['destinataire']!, _destinataireMeta));
    } else if (isInserting) {
      context.missing(_destinataireMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
          _jobIdMeta, jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta));
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('retrieve_date')) {
      context.handle(
          _retrieveDateMeta,
          retrieveDate.isAcceptableOrUnknown(
              data['retrieve_date']!, _retrieveDateMeta));
    }
    if (data.containsKey('sent_date')) {
      context.handle(_sentDateMeta,
          sentDate.isAcceptableOrUnknown(data['sent_date']!, _sentDateMeta));
    }
    if (data.containsKey('delivered_date')) {
      context.handle(
          _deliveredDateMeta,
          deliveredDate.isAcceptableOrUnknown(
              data['delivered_date']!, _deliveredDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      destinataire: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destinataire'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      jobId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}job_id'])!,
      retrieveDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}retrieve_date']),
      sentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_date']),
      deliveredDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivered_date']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String destinataire;
  final String message;
  final String messageId;
  final int jobId;
  final DateTime? retrieveDate;
  final DateTime? sentDate;
  final DateTime? deliveredDate;
  const Message(
      {required this.id,
      required this.destinataire,
      required this.message,
      required this.messageId,
      required this.jobId,
      this.retrieveDate,
      this.sentDate,
      this.deliveredDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['destinataire'] = Variable<String>(destinataire);
    map['message'] = Variable<String>(message);
    map['message_id'] = Variable<String>(messageId);
    map['job_id'] = Variable<int>(jobId);
    if (!nullToAbsent || retrieveDate != null) {
      map['retrieve_date'] = Variable<DateTime>(retrieveDate);
    }
    if (!nullToAbsent || sentDate != null) {
      map['sent_date'] = Variable<DateTime>(sentDate);
    }
    if (!nullToAbsent || deliveredDate != null) {
      map['delivered_date'] = Variable<DateTime>(deliveredDate);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      destinataire: Value(destinataire),
      message: Value(message),
      messageId: Value(messageId),
      jobId: Value(jobId),
      retrieveDate: retrieveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(retrieveDate),
      sentDate: sentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(sentDate),
      deliveredDate: deliveredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredDate),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      destinataire: serializer.fromJson<String>(json['destinataire']),
      message: serializer.fromJson<String>(json['message']),
      messageId: serializer.fromJson<String>(json['messageId']),
      jobId: serializer.fromJson<int>(json['jobId']),
      retrieveDate: serializer.fromJson<DateTime?>(json['retrieveDate']),
      sentDate: serializer.fromJson<DateTime?>(json['sentDate']),
      deliveredDate: serializer.fromJson<DateTime?>(json['deliveredDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'destinataire': serializer.toJson<String>(destinataire),
      'message': serializer.toJson<String>(message),
      'messageId': serializer.toJson<String>(messageId),
      'jobId': serializer.toJson<int>(jobId),
      'retrieveDate': serializer.toJson<DateTime?>(retrieveDate),
      'sentDate': serializer.toJson<DateTime?>(sentDate),
      'deliveredDate': serializer.toJson<DateTime?>(deliveredDate),
    };
  }

  Message copyWith(
          {int? id,
          String? destinataire,
          String? message,
          String? messageId,
          int? jobId,
          Value<DateTime?> retrieveDate = const Value.absent(),
          Value<DateTime?> sentDate = const Value.absent(),
          Value<DateTime?> deliveredDate = const Value.absent()}) =>
      Message(
        id: id ?? this.id,
        destinataire: destinataire ?? this.destinataire,
        message: message ?? this.message,
        messageId: messageId ?? this.messageId,
        jobId: jobId ?? this.jobId,
        retrieveDate:
            retrieveDate.present ? retrieveDate.value : this.retrieveDate,
        sentDate: sentDate.present ? sentDate.value : this.sentDate,
        deliveredDate:
            deliveredDate.present ? deliveredDate.value : this.deliveredDate,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      destinataire: data.destinataire.present
          ? data.destinataire.value
          : this.destinataire,
      message: data.message.present ? data.message.value : this.message,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      retrieveDate: data.retrieveDate.present
          ? data.retrieveDate.value
          : this.retrieveDate,
      sentDate: data.sentDate.present ? data.sentDate.value : this.sentDate,
      deliveredDate: data.deliveredDate.present
          ? data.deliveredDate.value
          : this.deliveredDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('destinataire: $destinataire, ')
          ..write('message: $message, ')
          ..write('messageId: $messageId, ')
          ..write('jobId: $jobId, ')
          ..write('retrieveDate: $retrieveDate, ')
          ..write('sentDate: $sentDate, ')
          ..write('deliveredDate: $deliveredDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, destinataire, message, messageId, jobId,
      retrieveDate, sentDate, deliveredDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.destinataire == this.destinataire &&
          other.message == this.message &&
          other.messageId == this.messageId &&
          other.jobId == this.jobId &&
          other.retrieveDate == this.retrieveDate &&
          other.sentDate == this.sentDate &&
          other.deliveredDate == this.deliveredDate);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> destinataire;
  final Value<String> message;
  final Value<String> messageId;
  final Value<int> jobId;
  final Value<DateTime?> retrieveDate;
  final Value<DateTime?> sentDate;
  final Value<DateTime?> deliveredDate;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.destinataire = const Value.absent(),
    this.message = const Value.absent(),
    this.messageId = const Value.absent(),
    this.jobId = const Value.absent(),
    this.retrieveDate = const Value.absent(),
    this.sentDate = const Value.absent(),
    this.deliveredDate = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String destinataire,
    required String message,
    required String messageId,
    required int jobId,
    this.retrieveDate = const Value.absent(),
    this.sentDate = const Value.absent(),
    this.deliveredDate = const Value.absent(),
  })  : destinataire = Value(destinataire),
        message = Value(message),
        messageId = Value(messageId),
        jobId = Value(jobId);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? destinataire,
    Expression<String>? message,
    Expression<String>? messageId,
    Expression<int>? jobId,
    Expression<DateTime>? retrieveDate,
    Expression<DateTime>? sentDate,
    Expression<DateTime>? deliveredDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (destinataire != null) 'destinataire': destinataire,
      if (message != null) 'message': message,
      if (messageId != null) 'message_id': messageId,
      if (jobId != null) 'job_id': jobId,
      if (retrieveDate != null) 'retrieve_date': retrieveDate,
      if (sentDate != null) 'sent_date': sentDate,
      if (deliveredDate != null) 'delivered_date': deliveredDate,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? destinataire,
      Value<String>? message,
      Value<String>? messageId,
      Value<int>? jobId,
      Value<DateTime?>? retrieveDate,
      Value<DateTime?>? sentDate,
      Value<DateTime?>? deliveredDate}) {
    return MessagesCompanion(
      id: id ?? this.id,
      destinataire: destinataire ?? this.destinataire,
      message: message ?? this.message,
      messageId: messageId ?? this.messageId,
      jobId: jobId ?? this.jobId,
      retrieveDate: retrieveDate ?? this.retrieveDate,
      sentDate: sentDate ?? this.sentDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (destinataire.present) {
      map['destinataire'] = Variable<String>(destinataire.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (retrieveDate.present) {
      map['retrieve_date'] = Variable<DateTime>(retrieveDate.value);
    }
    if (sentDate.present) {
      map['sent_date'] = Variable<DateTime>(sentDate.value);
    }
    if (deliveredDate.present) {
      map['delivered_date'] = Variable<DateTime>(deliveredDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('destinataire: $destinataire, ')
          ..write('message: $message, ')
          ..write('messageId: $messageId, ')
          ..write('jobId: $jobId, ')
          ..write('retrieveDate: $retrieveDate, ')
          ..write('sentDate: $sentDate, ')
          ..write('deliveredDate: $deliveredDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [messages];
}

typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required String destinataire,
  required String message,
  required String messageId,
  required int jobId,
  Value<DateTime?> retrieveDate,
  Value<DateTime?> sentDate,
  Value<DateTime?> deliveredDate,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<String> destinataire,
  Value<String> message,
  Value<String> messageId,
  Value<int> jobId,
  Value<DateTime?> retrieveDate,
  Value<DateTime?> sentDate,
  Value<DateTime?> deliveredDate,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinataire => $composableBuilder(
      column: $table.destinataire, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jobId => $composableBuilder(
      column: $table.jobId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get retrieveDate => $composableBuilder(
      column: $table.retrieveDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentDate => $composableBuilder(
      column: $table.sentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinataire => $composableBuilder(
      column: $table.destinataire,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jobId => $composableBuilder(
      column: $table.jobId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get retrieveDate => $composableBuilder(
      column: $table.retrieveDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentDate => $composableBuilder(
      column: $table.sentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate,
      builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get destinataire => $composableBuilder(
      column: $table.destinataire, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<int> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<DateTime> get retrieveDate => $composableBuilder(
      column: $table.retrieveDate, builder: (column) => column);

  GeneratedColumn<DateTime> get sentDate =>
      $composableBuilder(column: $table.sentDate, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredDate => $composableBuilder(
      column: $table.deliveredDate, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> destinataire = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> messageId = const Value.absent(),
            Value<int> jobId = const Value.absent(),
            Value<DateTime?> retrieveDate = const Value.absent(),
            Value<DateTime?> sentDate = const Value.absent(),
            Value<DateTime?> deliveredDate = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            destinataire: destinataire,
            message: message,
            messageId: messageId,
            jobId: jobId,
            retrieveDate: retrieveDate,
            sentDate: sentDate,
            deliveredDate: deliveredDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String destinataire,
            required String message,
            required String messageId,
            required int jobId,
            Value<DateTime?> retrieveDate = const Value.absent(),
            Value<DateTime?> sentDate = const Value.absent(),
            Value<DateTime?> deliveredDate = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            destinataire: destinataire,
            message: message,
            messageId: messageId,
            jobId: jobId,
            retrieveDate: retrieveDate,
            sentDate: sentDate,
            deliveredDate: deliveredDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
