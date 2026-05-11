// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_dao.dart';

// ignore_for_file: type=lint
mixin _$TemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $SessionTemplatesTable get sessionTemplates =>
      attachedDatabase.sessionTemplates;
  TemplateDaoManager get managers => TemplateDaoManager(this);
}

class TemplateDaoManager {
  final _$TemplateDaoMixin _db;
  TemplateDaoManager(this._db);
  $$SessionTemplatesTableTableManager get sessionTemplates =>
      $$SessionTemplatesTableTableManager(
        _db.attachedDatabase,
        _db.sessionTemplates,
      );
}
