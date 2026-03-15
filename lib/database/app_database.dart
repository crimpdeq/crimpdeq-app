import 'package:drift/drift.dart';

import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

// ──────────────────────────── Tables ──────────────────────────────────

class Sessions extends Table {
  TextColumn get id => text()();
  IntColumn get protocolType => integer()();
  TextColumn get protocolConfigJson => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get peakForceKg => real().withDefault(const Constant(0.0))();
  RealColumn get avgPeakForceKg => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class TrainingSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  IntColumn get setIndex => integer()();
  IntColumn get restDurationMs => integer().withDefault(const Constant(0))();
}

class Reps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get trainingSetId => integer().references(TrainingSets, #id)();
  IntColumn get repIndex => integer()();
  RealColumn get peakForceKg => real()();
  RealColumn get avgForceKg => real()();
  IntColumn get durationMs => integer()();
  IntColumn get startTimestampMs => integer()();
  TextColumn get weightSamplesJson =>
      text().withDefault(const Constant('[]'))();
}

class PersonalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get protocolType => integer()();
  RealColumn get peakForceKg => real()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  DateTimeColumn get achievedAt => dateTime()();
}

// ──────────────────────────── Database ────────────────────────────────

@DriftDatabase(tables: [Sessions, TrainingSets, Reps, PersonalRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.executor);

  static AppDatabase? _instance;

  static Future<AppDatabase> getInstance() async {
    if (_instance != null) return _instance!;
    final executor = await impl.openConnection();
    _instance = AppDatabase._(executor);
    return _instance!;
  }

  @override
  int get schemaVersion => 1;
}
