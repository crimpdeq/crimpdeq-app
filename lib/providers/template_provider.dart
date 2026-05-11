import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/daos/template_dao.dart';
import '../models/session_models.dart';
import '../models/template_models.dart';
import 'database_provider.dart';

final templateDaoProvider = FutureProvider<TemplateDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return TemplateDao(db);
});

final templateListProvider =
    FutureProvider<List<SessionTemplate>>((ref) async {
  final dao = await ref.watch(templateDaoProvider.future);
  await _seedDefaultTemplates(dao);
  return dao.getAllTemplates();
});

Future<void> _seedDefaultTemplates(TemplateDao dao) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('templates_seeded') == true) return;

  final now = DateTime.now();
  final defaults = [
    SessionTemplate(
      id: 'default_repeater',
      name: 'Repeater',
      protocolConfig: const ProtocolConfig(
        type: ProtocolType.repeater,
        hangDurationSec: 7,
        restDurationSec: 3,
        sets: 6,
        repsPerSet: 6,
        restBetweenSetsSec: 120,
      ),
      createdAt: now,
    ),
    SessionTemplate(
      id: 'default_max_hang',
      name: 'Max Hang',
      protocolConfig: const ProtocolConfig(
        type: ProtocolType.maxHang,
        hangDurationSec: 7,
        restDurationSec: 3,
        sets: 3,
        repsPerSet: 1,
        restBetweenSetsSec: 180,
        handMode: HandMode.alternatePerSet,
      ),
      createdAt: now.subtract(const Duration(seconds: 1)),
    ),
    SessionTemplate(
      id: 'default_freeform',
      name: 'Freeform',
      protocolConfig: const ProtocolConfig(
        type: ProtocolType.freeform,
      ),
      createdAt: now.subtract(const Duration(seconds: 2)),
    ),
  ];

  for (final t in defaults) {
    await dao.insertTemplate(t);
  }
  await prefs.setBool('templates_seeded', true);
}
