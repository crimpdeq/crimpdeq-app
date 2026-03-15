import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/session_models.dart';

class ExportService {
  static Future<void> exportCsv(Session session) async {
    final buf = StringBuffer();
    buf.writeln('set,rep,peak_kg,avg_kg,duration_ms');
    for (var si = 0; si < session.sets.length; si++) {
      final trainingSet = session.sets[si];
      for (var ri = 0; ri < trainingSet.reps.length; ri++) {
        final rep = trainingSet.reps[ri];
        buf.writeln(
          '${si + 1},${ri + 1},'
          '${rep.peakForceKg.toStringAsFixed(2)},'
          '${rep.avgForceKg.toStringAsFixed(2)},'
          '${rep.durationMs}',
        );
      }
    }

    await _share(
      'crimpdeq_session_${session.id}.csv',
      buf.toString(),
      'text/csv',
    );
  }

  static Future<void> exportJson(Session session) async {
    final json = jsonEncode(session.toJson());
    await _share(
      'crimpdeq_session_${session.id}.json',
      json,
      'application/json',
    );
  }

  static Future<void> _share(
    String filename,
    String content,
    String mimeType,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, filename));
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
    );
  }
}
