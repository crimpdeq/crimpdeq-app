// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grip_dao.dart';

// ignore_for_file: type=lint
mixin _$GripDaoMixin on DatabaseAccessor<AppDatabase> {
  $GripsTable get grips => attachedDatabase.grips;
  GripDaoManager get managers => GripDaoManager(this);
}

class GripDaoManager {
  final _$GripDaoMixin _db;
  GripDaoManager(this._db);
  $$GripsTableTableManager get grips =>
      $$GripsTableTableManager(_db.attachedDatabase, _db.grips);
}
