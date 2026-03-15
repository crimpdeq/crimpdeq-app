// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $SessionsTable get sessions => attachedDatabase.sessions;
  $TrainingSetsTable get trainingSets => attachedDatabase.trainingSets;
  $RepsTable get reps => attachedDatabase.reps;
  $PersonalRecordsTable get personalRecords => attachedDatabase.personalRecords;
  SessionDaoManager get managers => SessionDaoManager(this);
}

class SessionDaoManager {
  final _$SessionDaoMixin _db;
  SessionDaoManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$TrainingSetsTableTableManager get trainingSets =>
      $$TrainingSetsTableTableManager(_db.attachedDatabase, _db.trainingSets);
  $$RepsTableTableManager get reps =>
      $$RepsTableTableManager(_db.attachedDatabase, _db.reps);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(
        _db.attachedDatabase,
        _db.personalRecords,
      );
}
