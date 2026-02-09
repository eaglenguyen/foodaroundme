import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';


class Places extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get categories => text()();  // JSON Strings
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  IntColumn get lastFetched =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

}

@DriftDatabase(tables: [Places])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;


}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'places.db'));
    return NativeDatabase(file);
  });
}

