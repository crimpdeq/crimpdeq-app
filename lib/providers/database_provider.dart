import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/session_dao.dart';
import '../models/session_models.dart' as models;
import '../services/mock_data_service.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase.getInstance();
});

final sessionDaoProvider = FutureProvider<SessionDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = SessionDao(db);
  // Seed mock history data in debug mode (no-op if data exists)
  await seedMockSessions(dao);
  return dao;
});

final sessionHistoryProvider =
    FutureProvider<List<models.Session>>((ref) async {
  try {
    final dao = await ref.watch(sessionDaoProvider.future);
    return dao.getAllSessions();
  } catch (_) {
    return [];
  }
});

final personalRecordsProvider =
    FutureProvider<Map<models.ProtocolType, double>>((ref) async {
  try {
    final dao = await ref.watch(sessionDaoProvider.future);
    return dao.getPersonalRecords();
  } catch (_) {
    return {};
  }
});
