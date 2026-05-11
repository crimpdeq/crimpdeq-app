import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../database/daos/grip_dao.dart';
import '../models/grip_models.dart';
import 'database_provider.dart';

final gripDaoProvider = FutureProvider<GripDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return GripDao(db);
});

final gripListProvider = FutureProvider<List<Grip>>((ref) async {
  final dao = await ref.watch(gripDaoProvider.future);
  return dao.getAllGrips();
});

/// Provides a lookup map of grip ID -> Grip for efficient access in list views.
final gripMapProvider = FutureProvider<Map<String, Grip>>((ref) async {
  final grips = await ref.watch(gripListProvider.future);
  return {for (final g in grips) g.id: g};
});

/// Returns the grip ID from the most recent session that had one set.
final lastUsedGripIdProvider = FutureProvider<String?>((ref) async {
  final sessions = await ref.watch(sessionHistoryProvider.future);
  for (final s in sessions) {
    if (s.protocolConfig.gripId != null) return s.protocolConfig.gripId;
  }
  return null;
});
